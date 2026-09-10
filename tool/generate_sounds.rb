#!/usr/bin/env ruby
# frozen_string_literal: true

# Regenerates the answer-feedback sounds in assets/sounds/.
#
# The originals were between one and three and a half seconds long and ranged
# over seven LUFS, so a verdict cue was still playing while the learner
# answered the next exercise, and half of them blared while half whispered.
#
# What makes these sound like an instrument rather than a beep:
#
#   * **Inharmonic partials.** A struck bar or bell has partials at non-integer
#     multiples of its fundamental. Stack exact integers instead and the ear
#     hears an organ.
#   * **Per-partial decay.** The high partials die first. This, more than the
#     spectrum itself, is what says "something was struck".
#   * **A mallet transient.** A few milliseconds of filtered noise at the onset
#     supplies the physical knock that additive tone alone cannot.
#   * **A short tail.** A little room behind the note keeps it from sounding
#     like it was recorded inside a box.
#
# The wrong answer is a soft low-passed thud that sags in pitch: dark, quiet,
# and over quickly. A mistake is meant to send you back for more practice, not
# to tell you off, so it peaks 3dB below the correct cue.
#
#   ruby tool/generate_sounds.rb
#
# Needs ffmpeg on PATH for the WAV to MP3 step.

require 'pathname'
require 'tmpdir'

ROOT = Pathname.new(__dir__).parent
OUT = ROOT / 'assets' / 'sounds'
RATE = 44_100

# [relative frequency, amplitude, decay rate relative to the fundamental]
#
# Stretched slightly away from whole numbers, the way a real bar is, and the
# upper partials decay two to four times faster than the fundamental.
BELL_PARTIALS = [
  [1.000, 1.00, 1.00],
  [2.007, 0.48, 0.62],
  [3.011, 0.24, 0.44],
  [4.972, 0.13, 0.30],
  [6.803, 0.07, 0.22],
  [9.110, 0.03, 0.16]
].freeze

# A saw rolled off hard: warm, dull, no bite.
THUD_PARTIALS = (1..7).map do |n|
  cutoff = 2.4
  [n.to_f, (1.0 / n) / (1.0 + (n / cutoff)**2.4), 1.0 - (n * 0.06)]
end.freeze

# [frequency Hz, start ms, length ms]
VOICES = {
  'level_up_1' => [[880.00, 0, 300], [1318.51, 85, 420]],
  'level_up_2' => [[987.77, 0, 280], [1479.98, 80, 430]],
  'level_up_3' => [[783.99, 0, 240], [1046.50, 70, 260], [1567.98, 145, 420]],
  'level_up_4' => [[1046.50, 0, 290], [1760.00, 85, 420]],

  'error_1' => [[196.00, 0, 190], [155.56, 105, 260]],
  'error_2' => [[174.61, 0, 190], [138.59, 105, 260]],
  'error_3' => [[164.81, 0, 300]],
  'error_4' => [[185.00, 0, 180], [146.83, 100, 260]]
}.freeze

def correct?(name) = name.start_with?('level_up')

# Deterministic noise, so a re-run produces the file that was reviewed.
class Noise
  def initialize(seed) = @state = seed
  def next_value
    @state = (@state * 1_103_515_245 + 12_345) & 0x7fffffff
    (@state / 1_073_741_823.5) - 1.0
  end
end

def render_voice(frequency, length_ms, correct, noise)
  length = (RATE * length_ms / 1000.0).round
  samples = Array.new(length, 0.0)
  seconds = length_ms / 1000.0
  # A bell rings on; a thud is gone almost immediately.
  base_tau = correct ? seconds / 2.6 : seconds / 5.0
  attack = correct ? 0.0025 : 0.010
  partials = correct ? BELL_PARTIALS : THUD_PARTIALS

  # Phase accumulators, so a glide does not tear the waveform.
  phases = Array.new(partials.length, 0.0)

  length.times do |index|
    t = index.to_f / RATE
    # The miss sags in pitch. That sag is what reads as "no".
    glide = correct ? 1.0 : (1.0 - 0.10 * (t / seconds))

    value = 0.0
    partials.each_with_index do |(multiple, weight, decay), slot|
      phases[slot] += 2 * Math::PI * frequency * multiple * glide / RATE
      value += weight * Math.sin(phases[slot]) * Math.exp(-t / (base_tau * decay))
    end

    envelope = 1.0
    envelope *= (t / attack) if t < attack
    remaining = (length - index).to_f / RATE
    envelope *= (remaining / 0.015) if remaining < 0.015

    samples[index] = value * envelope
  end

  # The mallet: a short filtered knock that gives the onset a body.
  strike_ms = correct ? 7 : 14
  strike = (RATE * strike_ms / 1000.0).round
  previous = 0.0
  strike.times do |index|
    t = index.to_f / RATE
    # One-pole low pass, opened wider for the bright cue.
    previous += ((correct ? 0.28 : 0.09) * (noise.next_value - previous))
    samples[index] += previous * (correct ? 0.22 : 0.32) *
                      Math.exp(-t / (strike_ms / 1000.0 / 3.0))
  end

  samples
end

# Four combs and two allpasses: enough room to stop the note sounding boxed in,
# short enough that the tail is over before the learner answers again.
def reverb(samples, wet)
  combs = [[1327, 0.72], [1523, 0.70], [1723, 0.68], [1871, 0.66]]
  tail = Array.new(samples.length + 8_000, 0.0)
  samples.each_with_index { |value, index| tail[index] = value }

  wet_signal = Array.new(tail.length, 0.0)
  combs.each do |delay, feedback|
    buffer = Array.new(tail.length, 0.0)
    tail.each_index do |index|
      buffer[index] = tail[index]
      buffer[index] += buffer[index - delay] * feedback if index >= delay
      wet_signal[index] += buffer[index] * 0.25
    end
  end

  [[221, 0.7], [79, 0.7]].each do |delay, gain|
    out = Array.new(wet_signal.length, 0.0)
    wet_signal.each_index do |index|
      delayed = index >= delay ? wet_signal[index - delay] : 0.0
      out[index] = -gain * wet_signal[index] + delayed +
                   (index >= delay ? gain * out[index - delay] : 0.0)
    end
    wet_signal = out
  end

  tail.each_index.map { |index| tail[index] + wet_signal[index] * wet }
end

def render(name)
  correct = correct?(name)
  noise = Noise.new(name.bytes.sum * 7919)
  voices = VOICES.fetch(name)
  total_ms = voices.map { |(_, start, length)| start + length }.max
  samples = Array.new((RATE * (total_ms + 40) / 1000.0).ceil, 0.0)

  voices.each do |frequency, start_ms, length_ms|
    offset = (RATE * start_ms / 1000.0).round
    voice = render_voice(frequency, length_ms, correct, noise)
    voice.each_with_index do |value, index|
      position = offset + index
      samples[position] += value if position < samples.length
    end
  end

  faded = reverb(samples, correct ? 0.16 : 0.10)
  # Trim the tail once it is inaudible rather than shipping silence.
  threshold = faded.map(&:abs).max * 0.0015
  last = faded.rindex { |value| value.abs > threshold } || faded.length - 1
  faded[0..last]
end

def peak_normalise(samples, target_db)
  peak = samples.map(&:abs).max
  return samples if peak.nil? || peak.zero?

  gain = (10**(target_db / 20.0)) / peak
  samples.map { |value| value * gain }
end

def write_wav(path, samples)
  data = samples.map { |value| (value.clamp(-1.0, 1.0) * 32_767).round }.pack('s<*')
  header = +'RIFF'
  header << [36 + data.bytesize].pack('V')
  header << 'WAVEfmt '
  header << [16, 1, 1, RATE, RATE * 2, 2, 16].pack('VvvVVvv')
  header << 'data'
  header << [data.bytesize].pack('V')
  path.binwrite(header + data)
end

Dir.mktmpdir do |tmp|
  VOICES.each_key do |name|
    samples = peak_normalise(render(name), correct?(name) ? -3.0 : -6.0)
    wav = Pathname.new(tmp) / "#{name}.wav"
    write_wav(wav, samples)

    mp3 = OUT / "#{name}.mp3"
    ok = system('ffmpeg', '-y', '-loglevel', 'error', '-i', wav.to_s,
                '-codec:a', 'libmp3lame', '-q:a', '3', '-ar', '44100',
                '-ac', '1', mp3.to_s)
    abort "ffmpeg failed for #{name}" unless ok

    puts format('%-12s %5.0f ms  %6d bytes', name,
                samples.length.to_f / RATE * 1000, mp3.size)
  end
end
