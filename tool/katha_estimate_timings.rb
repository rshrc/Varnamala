#!/usr/bin/env ruby
# frozen_string_literal: true

# Fills in word timings for recordings that came back without them.
#
# ElevenLabs returns, with each recording, when every character is spoken,
# and the reader moves its highlight by that. Now and then the alignment comes
# back empty and every word reads 0-0, so the highlight never moves. This
# estimates timings from the audio instead: ffmpeg finds the pauses, each
# sentence is placed in a stretch of speech (the longest pauses separate the
# sentences), and a sentence's words share its stretch by their length.
# Close enough for a highlight that moves three words at a time.
#
#   ruby tool/katha_estimate_timings.rb            # every line with no timings
#   ruby tool/katha_estimate_timings.rb --dry-run  # say which, change nothing
#
# Needs ffmpeg, and the MP3s (ruby tool/katha_cdn.rb pull). Estimated rows are
# marked "estimated" in stories/<series>/recordings/<lang>/<episode>.yaml;
# re-recording a line replaces its row with real timings.

require 'open3'
require_relative 'lib/katha_story'

SERIES = 'dev-in-the-city'
GAP_MS = 40 # breath left between two words in one stretch

# Spans of speech, [start, end] in ms: everything that is not a pause.
def speech(path)
  _, log, = Open3.capture3('ffmpeg', '-hide_banner', '-i', path, '-af', 'silencedetect=noise=-35dB:d=0.12', '-f', 'null', '-')
  duration = log[/Duration: (\d+):(\d+):([\d.]+)/] && ((Regexp.last_match(1).to_i * 3600) + (Regexp.last_match(2).to_i * 60) + Regexp.last_match(3).to_f) * 1000
  raise "#{path}: ffmpeg could not read it" unless duration

  starts = log.scan(/silence_start: ([\d.]+)/).flatten.map { |t| (t.to_f * 1000).round }
  ends = log.scan(/silence_end: ([\d.]+)/).flatten.map { |t| (t.to_f * 1000).round }
  pauses = starts.each_with_index.map { |s, i| [s, ends[i] || duration.round] }
  spans = []
  cursor = 0
  pauses.each do |from, to|
    spans << [cursor, from] if from > cursor
    cursor = to
  end
  spans << [cursor, duration.round] if duration.round > cursor
  spans.select { |a, b| b - a > 60 }
end

# Merges spans until there are [count], closing the shortest pauses first,
# so the pauses left are the ones between sentences.
def into(spans, count)
  spans = spans.map(&:dup)
  while spans.size > count
    i = (0...spans.size - 1).min_by { |k| spans[k + 1][0] - spans[k][1] }
    spans[i] = [spans[i][0], spans[i + 1][1]]
    spans.delete_at(i + 1)
  end
  spans
end

# Shares [span] among [words] by how long each is written.
def spread(span, words)
  weights = words.map { |w| [w.length, 2].max }
  usable = span[1] - span[0] - (GAP_MS * (words.size - 1))
  at = span[0].to_f
  weights.map do |weight|
    length = usable * weight / weights.sum.to_f
    timing = [at.round, (at + length).round]
    at += length + GAP_MS
    timing
  end
end

# The line's word indexes, grouped by sentence.
def sentences(native, tokens)
  groups = [[]]
  cursor = 0
  tokens.each_with_index do |token, i|
    at = native.index(token['n'], cursor) || cursor
    cursor = at + token['n'].length
    groups.last << i
    groups << [] if native[cursor..].to_s.match?(KathaStory::SENTENCE_END) && i < tokens.size - 1
  end
  groups
end

dry = ARGV.delete('--dry-run')
series = KathaStory::Series.load(SERIES)
fixed = 0
series.languages.each do |lang|
  book = series.recordings[lang]
  book.episodes.each do |episode, beats|
    telling = File.join(KathaStory::OUTPUT, SERIES, episode, 'tellings', "#{lang}.telling.json")
    lines = JSON.parse(File.read(telling))['beats']
    beats.each do |beat, line|
      next unless line.timings.all? { |t| t.nil? || t[1].zero? }

      mp3 = File.join(KathaStory::OUTPUT, SERIES, 'audio', lang, KathaStory::Recordings.line_file(episode, beat))
      abort "#{mp3} is missing: ruby tool/katha_cdn.rb pull #{lang}" unless File.exist?(mp3)

      tokens = lines.fetch(beat)['tokens']
      groups = sentences(lines[beat]['n'], tokens)
      found = speech(mp3)
      spans = found.size >= groups.size ? into(found, groups.size) : [[found.first[0], found.last[1]]]
      groups = [tokens.each_index.to_a] if spans.size == 1
      timings = []
      groups.each_with_index do |group, g|
        timings.concat(spread(spans[g], group.map { |i| tokens[i]['n'] }))
      end
      puts "#{lang} #{episode} #{beat}: #{timings.map { |t| t.join('-') }.join(' ')}"
      book.record_line(episode, beat, line.fingerprint, timings, note: 'estimated') unless dry
      fixed += 1
    end
  end
  book.save unless dry
end
puts dry ? "#{fixed} lines would be estimated" : "#{fixed} lines estimated; now ruby tool/katha_build.rb"
