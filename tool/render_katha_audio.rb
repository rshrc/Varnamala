#!/usr/bin/env ruby
# frozen_string_literal: true

# Records Katha lines and words with ElevenLabs.
#
#   export ELEVENLABS_API_KEY=...            # never commit it
#   ruby tool/render_katha_audio.rb --dry-run            # what it would send, and the cost
#   ruby tool/render_katha_audio.rb                      # every episode, kn + hi, lines + words
#   ruby tool/render_katha_audio.rb --lang kn --episode s1e01 --beats b04-b14
#   ruby tool/render_katha_audio.rb --voices kn          # browse Voice Library voices for casting
#   ruby tool/render_katha_audio.rb --add-voice OWNER_ID VOICE_ID "Raju kn"
#
# It reads the stories from stories/<series>/ (compiling them first), and
# writes, under assets/katha/<series>/audio/<lang>/:
#   <episode>-<beat>.mp3    one file per line, every sentence of it   (not in git)
#   words/<hash>.mp3        one file per distinct word form           (not in git)
# and, in git, under stories/<series>/recordings/<lang>/:
#   <episode>.yaml          each line's fingerprint, and when each word is
#                           spoken (from the alignment ElevenLabs returns)
#   words.yaml              the words recorded on their own
# then compiles again, which puts each line's recording and timings into the
# app's JSON. The MP3s are served from Cloudflare: push them afterwards with
#   ruby tool/katha_cdn.rb push
#
# Emotion never reaches the screen. A line is sent as its native text with v3
# audio tags in front of its sentences: the scene beat's `tags`, or the default
# for its `delivery` from voices.yaml. The learner reads the plain line.
#
# Cached by text + voice + model + settings: re-running only records what
# changed. --max-credits refuses a run that would cost more than it says.

require 'base64'
require 'digest'
require 'fileutils'
require 'json'
require 'net/http'
require 'optparse'
require 'uri'
require_relative 'lib/katha_story'

ROOT = File.expand_path('..', __dir__)
API = 'https://api.elevenlabs.io'
SENTENCE_END = /(?<=[.!?।॥۔؟])\s+/
PUNCTUATION = /[.,!?;:।॥۔،؟…"“”‘’]/

opts = {
  series: 'dev-in-the-city', langs: %w[kn hi], episodes: nil, beats: nil,
  lines: true, words: true, dry: false, force: false, max_credits: 3000,
  concurrency: 2
}
mode = :render
voice_query = nil
add_voice = nil
OptionParser.new do |o|
  o.banner = 'usage: ruby tool/render_katha_audio.rb [options]'
  o.on('--series NAME') { |v| opts[:series] = v }
  o.on('--lang LIST', 'kn,hi') { |v| opts[:langs] = v.split(',') }
  o.on('--episode LIST', 's1e01,s1e02') { |v| opts[:episodes] = v.split(',') }
  o.on('--beats RANGE', 'b04-b14 or b01,b07') { |v| opts[:beats] = v }
  o.on('--no-lines') { opts[:lines] = false }
  o.on('--no-words') { opts[:words] = false }
  o.on('--dry-run') { opts[:dry] = true }
  o.on('--force', 're-record even if cached') { opts[:force] = true }
  o.on('--max-credits N', Integer) { |v| opts[:max_credits] = v }
  o.on('--concurrency N', Integer) { |v| opts[:concurrency] = v }
  o.on('--voices LANG', 'list Voice Library voices for a language') do |v|
    mode = :voices
    voice_query = v
  end
  o.on('--add-voice OWNER,VOICE,NAME', Array, 'add a library voice to your account') do |v|
    mode = :add_voice
    add_voice = v
  end
end.parse!

def key!
  ENV.fetch('ELEVENLABS_API_KEY') { abort 'Set ELEVENLABS_API_KEY first.' }
end

def request(method, path, body: nil, query: {})
  uri = URI("#{API}#{path}")
  uri.query = URI.encode_www_form(query) unless query.empty?
  req = (method == :post ? Net::HTTP::Post : Net::HTTP::Get).new(uri)
  req['xi-api-key'] = key!
  req['Content-Type'] = 'application/json'
  req.body = JSON.generate(body) if body
  attempts = 0
  loop do
    res = Net::HTTP.start(uri.host, uri.port, use_ssl: true, read_timeout: 120) { |h| h.request(req) }
    return res if res.is_a?(Net::HTTPSuccess)
    attempts += 1
    if (res.code == '429' || res.code.start_with?('5')) && attempts < 5
      sleep(2**attempts)
      next
    end
    detail = (JSON.parse(res.body)['detail'] rescue res.body)
    raise "#{res.code} #{path}: #{detail.is_a?(Hash) ? detail['message'] || detail : detail}"
  end
end

# ------------------------------------------------------------------ casting

if mode == :voices
  res = request(:get, '/v1/shared-voices',
                query: { language: voice_query, page_size: 100, sort: 'usage_character_count_1y' })
  JSON.parse(res.body)['voices'].each do |v|
    puts [v['voice_id'], v['public_owner_id'], v['name'], v['gender'], v['age'], v['accent'],
          v['descriptive'], v['use_case'], v['preview_url']].join(' | ')
  end
  exit
end

if mode == :add_voice
  owner, voice, name = add_voice
  res = request(:post, "/v1/voices/add/#{owner}/#{voice}", body: { new_name: name })
  puts JSON.parse(res.body)['voice_id']
  exit
end

# ------------------------------------------------------------------ plan

# Record what the stories say now, not what was last compiled.
begin
  KathaStory.build(opts[:series])
rescue KathaStory::Error => e
  abort e.message
end
series_dir = File.join(ROOT, 'assets/katha', opts[:series])
voices = KathaStory::Voices.load(opts[:series])
recordings = Hash.new { |h, lang| h[lang] = KathaStory::Recordings.load(opts[:series], lang) }
episodes = opts[:episodes] || KathaStory.episodes(opts[:series])

def beat_filter(spec)
  return nil unless spec
  spec.split(',').flat_map do |part|
    from, to = part.split('-')
    to ? (from..to).to_a : [from]
  end
end
only_beats = beat_filter(opts[:beats])

def word_key(native) = native.gsub(PUNCTUATION, '').strip

jobs = []
tellings = {}
episodes.each do |episode|
  scene = JSON.parse(File.read(File.join(series_dir, episode, "#{episode}.scene.json")))
  opts[:langs].each do |lang|
    path = File.join(series_dir, episode, 'tellings', "#{lang}.telling.json")
    next unless File.exist?(path)
    telling = JSON.parse(File.read(path))
    tellings[path] = { telling: telling, episode: episode, lang: lang }
    next unless opts[:lines]
    scene['beats'].each do |beat|
      next if only_beats && !only_beats.include?(beat['id'])
      line = telling['beats'][beat['id']] or abort "#{episode}/#{lang} has no #{beat['id']}"
      jobs << {
        kind: :line, lang: lang, episode: episode, beat: beat['id'],
        voice: voices.voice(lang, beat['speaker']), text: voices.spoken(line['n'], voices.tags(beat)),
        tokens: line['tokens'], file: KathaStory::Recordings.line_file(episode, beat['id']),
        hash: voices.line_fingerprint(lang, beat, line['n'])
      }
    end
  end
end

if opts[:words]
  opts[:langs].each do |lang|
    voice = voices.word_voice(lang)
    settings = voices.word_settings(lang)
    forms = tellings.values.select { |t| t[:lang] == lang }
                    .flat_map { |t| t[:telling]['beats'].values.flat_map { |b| b['tokens'].map { |tk| word_key(tk['n']) } } }
                    .reject(&:empty?).uniq
    forms.each do |form|
      text = "#{form}."
      jobs << {
        kind: :word, lang: lang, form: form, voice: voice, text: text,
        file: KathaStory::Recordings.word_file(form), hash: settings
      }
    end
  end
end

def audio_dir(series_dir, lang, kind)
  File.join(series_dir, 'audio', lang, *(kind == :word ? ['words'] : []))
end

def recorded?(recordings, job)
  book = recordings[job[:lang]]
  return book.word?(job[:form], job[:hash]) if job[:kind] == :word

  book.line(job[:episode], job[:beat])&.fingerprint == job[:hash]
end

# A matching fingerprint means it is recorded, whether or not this checkout
# has the MP3: the file lives on Cloudflare, and `katha_cdn.rb pull` fetches it.
todo = jobs.reject { |job| !opts[:force] && recorded?(recordings, job) }

# A line whose exact recording already exists under another beat - it moved,
# or was copied - is copied rather than recorded again: same text, voice and
# settings make the same hash. The timings travel with it.
unless opts[:force]
  earlier = Hash.new { |h, lang| h[lang] = {} }
  opts[:langs].each do |lang|
    recordings[lang].episodes.each do |episode, beats|
      beats.each do |beat, line|
        path = File.join(audio_dir(series_dir, lang, :line), KathaStory::Recordings.line_file(episode, beat))
        earlier[lang][line.fingerprint] = { 'path' => path, 't' => line.timings } if File.exist?(path)
      end
    end
  end
  todo.each do |job|
    next unless job[:kind] == :line

    entry = earlier[job[:lang]][job[:hash]]
    job[:reuse] = entry if entry
  end
end
reused, todo = todo.partition { |j| j[:reuse] }
# Read every source before writing any target: one beat's old file can be
# another beat's new name.
sources = (opts[:dry] ? [] : reused).to_h { |job| [job, File.binread(job[:reuse]['path'])] }
sources.each do |job, bytes|
  dir = audio_dir(series_dir, job[:lang], :line)
  File.binwrite(File.join(dir, job[:file]), bytes)
  job[:t] = job[:reuse]['t']
  recordings[job[:lang]].record_line(job[:episode], job[:beat], job[:hash], job[:t])
end
puts "#{reused.size} lines reused from earlier recordings" unless reused.empty?
credits = todo.sum { |j| j[:text].length }

puts "#{jobs.size} recordings, #{todo.size} to make, about #{credits} credits " \
     "(#{todo.count { |j| j[:kind] == :line }} lines, #{todo.count { |j| j[:kind] == :word }} words)"
if opts[:dry]
  todo.each { |j| puts "  #{j[:lang]} #{j[:kind] == :line ? "#{j[:episode]}/#{j[:beat]}" : 'word'}  #{j[:text]}" }
  exit
end
abort "That is over --max-credits #{opts[:max_credits]}. Raise it to go ahead." if credits > opts[:max_credits]

# ------------------------------------------------------------------ record

# Each token's [start, end] in ms, found in the alignment in order. The tags
# are in the alignment too, so tokens are searched for rather than counted.
def timings(alignment, tokens)
  return [] unless alignment
  chars = alignment['characters']
  starts = alignment['character_start_times_seconds']
  ends = alignment['character_end_times_seconds']
  joined = +''
  owner = []
  chars.each_with_index do |c, i|
    joined << c
    c.length.times { owner << i }
  end
  cursor = 0
  tokens.map do |token|
    key = word_key(token['n'])
    at = key.empty? ? nil : joined.index(key, cursor)
    next nil unless at
    last = at + key.length - 1
    cursor = last + 1
    [(starts[owner[at]] * 1000).round, (ends[owner[last]] * 1000).round]
  end
end

spent = 0
failures = []
lock = Mutex.new
queue = Queue.new
todo.each { |j| queue << j }
workers = Array.new(opts[:concurrency]) do
  Thread.new do
    while (job = (queue.pop(true) rescue nil))
      begin
        res = request(:post, "/v1/text-to-speech/#{job[:voice]}/with-timestamps",
                      query: { output_format: voices.output_format },
                      body: { text: job[:text], model_id: voices.model, language_code: job[:lang],
                              voice_settings: voices.settings })
        body = JSON.parse(res.body)
        dir = audio_dir(series_dir, job[:lang], job[:kind])
        FileUtils.mkdir_p(dir)
        File.binwrite(File.join(dir, job[:file]), Base64.decode64(body['audio_base64']))
        job[:t] = timings(body['alignment'], job[:tokens]) if job[:kind] == :line
        lock.synchronize do
          spent += (res['character-cost'] || job[:text].length).to_i
          if job[:kind] == :word
            recordings[job[:lang]].record_word(job[:form], job[:hash])
          else
            recordings[job[:lang]].record_line(job[:episode], job[:beat], job[:hash], job[:t])
          end
          puts "  ok  #{job[:lang]} #{job[:kind] == :line ? "#{job[:episode]}/#{job[:beat]}" : job[:form]}"
        end
      rescue StandardError => e
        lock.synchronize { failures << "#{job[:lang]} #{job[:beat] || job[:form]}: #{e.message}" }
      end
    end
  end
end
workers.each(&:join)

# ------------------------------------------------------------------ write back

recordings.each_value(&:save)

# Compile again: each line picks up its recording and word timings from the
# index just written. A line with no recording reads with the device voice.
begin
  KathaStory.build(opts[:series])
rescue KathaStory::Error => e
  warn e.message
end

puts "spent #{spent} credits"
unless failures.empty?
  warn "#{failures.size} failed:"
  failures.first(20).each { |f| warn "  #{f}" }
  exit 1
end
