# frozen_string_literal: true

require 'digest'
require 'fileutils'
require 'json'
require 'yaml'

module KathaStory
  # How a series sounds: the ElevenLabs model and settings, each character's
  # voice per language, and the emotion tag each delivery gets.
  # Read from stories/<series>/voices.yaml.
  class Voices
    SENTENCE_END = /(?<=[.!?।॥۔؟])\s+/

    attr_reader :config

    def self.load(series)
      new(YAML.safe_load_file(File.join(SOURCE, series, 'voices.yaml')))
    end

    def initialize(config)
      @config = config
    end

    def model = config.fetch('model')
    def output_format = config.fetch('output_format')
    def settings = config.fetch('settings')
    def languages = config.fetch('voices').keys

    def voice(lang, speaker)
      config.dig('voices', lang, speaker) or raise ArgumentError, "voices.yaml: no #{lang} voice for #{speaker}"
    end

    def word_voice(lang) = voice(lang, config.fetch('word_voice'))

    # The tags a line is spoken with: the beat's own, else its delivery's.
    def tags(beat) = beat['tags'] || [config.fetch('delivery_tags')[beat['delivery']]].compact

    # What ElevenLabs is sent for a line: each sentence behind its tag. One
    # tag directs the whole line; a list directs sentence by sentence.
    def spoken(native, tags)
      sentences = native.split(SENTENCE_END).reject { |s| s.strip.empty? }
      sentences.each_with_index.map { |s, i| tags[i] ? "[#{tags[i]}] #{s}" : s }.join(' ')
    end

    # Identifies a recording by everything that shapes how it sounds: change
    # the text, the voice or a setting, and it no longer matches.
    def line_fingerprint(lang, beat, native)
      fingerprint(model, voice(lang, beat['speaker']), settings, output_format, spoken(native, tags(beat)), lang)
    end

    def word_fingerprint(lang, form) = fingerprint(model, word_voice(lang), settings, output_format, "#{form}.", lang)

    # Every word in a language is recorded the same way, so one fingerprint
    # covers them all.
    def word_settings(lang) = fingerprint(model, word_voice(lang), settings, output_format, lang)

    def self.fingerprint(*parts) = Digest::SHA256.hexdigest(JSON.generate(parts))[0, 16]

    private

    def fingerprint(*parts) = self.class.fingerprint(*parts)
  end

  # What has been recorded in one language, and when each word of each line
  # is spoken. Kept in git as YAML, one row per recording:
  #
  #   stories/<series>/recordings/<lang>/s1e01.yaml
  #     b05: dd1d10c078a03edd  80-480 640-1360
  #     (fingerprint, then each word's start-end in ms; "-" if unfound;
  #      a trailing "estimated" if the timings were estimated, not measured)
  #
  #   stories/<series>/recordings/<lang>/words.yaml
  #     settings: 3f2a9c0e1b7d4a55
  #     words:
  #       - ದೇವ್
  #     (the words recorded on their own, all with those settings)
  #
  # The MP3s themselves are on Cloudflare, named from these: a line is
  # <episode>-<beat>.mp3, a word is words/<first 10 of its SHA-1>.mp3.
  class Recordings
    LANGUAGE_NAMES = { 'kn' => 'Kannada', 'hi' => 'Hindi', 'ta' => 'Tamil', 'te' => 'Telugu', 'ml' => 'Malayalam', 'bn' => 'Bengali',
                       'mr' => 'Marathi', 'gu' => 'Gujarati', 'or' => 'Odia', 'as' => 'Assamese', 'ne' => 'Nepali',
                       'sa' => 'Sanskrit', 'ur' => 'Urdu' }.freeze

    # [note] is a remark kept at the end of the row, such as "estimated".
    Line = Struct.new(:fingerprint, :timings, :note)

    attr_reader :series, :lang, :words
    attr_accessor :word_settings

    def self.dir(series, lang) = File.join(SOURCE, series, 'recordings', lang)

    def self.word_file(form) = "#{Digest::SHA1.hexdigest(form)[0, 10]}.mp3"

    def self.line_file(episode, beat) = "#{episode}-#{beat}.mp3"

    def self.load(series, lang)
      new(series, lang).tap(&:read)
    end

    def initialize(series, lang)
      @series = series
      @lang = lang
      @episodes = Hash.new { |h, k| h[k] = {} }
      @words = []
      @word_settings = nil
    end

    def dir = self.class.dir(series, lang)

    # episode -> beat -> Line
    def episodes = @episodes

    def line(episode, beat) = @episodes.fetch(episode, {})[beat]

    def record_line(episode, beat, fingerprint, timings, note: nil)
      @episodes[episode][beat] = Line.new(fingerprint, timings, note)
    end

    def word?(form, settings) = word_settings == settings && @words.include?(form)

    def record_word(form, settings)
      if word_settings != settings
        @word_settings = settings
        @words = []
      end
      @words << form unless @words.include?(form)
    end

    # Every file the language's site serves, relative to its root.
    def files
      lines = @episodes.flat_map { |episode, beats| beats.keys.map { |beat| self.class.line_file(episode, beat) } }
      lines + @words.map { |form| "words/#{self.class.word_file(form)}" }
    end

    # The app's word index: a word to its file. Generated for the site, not kept.
    def word_index = { 'words' => @words.to_h { |form| [form, self.class.word_file(form)] } }

    def read
      Dir[File.join(dir, 's*e*.yaml')].each do |path|
        episode = File.basename(path, '.yaml')
        (YAML.safe_load_file(path) || {}).each do |beat, row|
          fingerprint, *times = row.to_s.split
          note = times.pop if times.last == 'estimated'
          timings = times.map { |t| t == '-' ? nil : t.split('-').map(&:to_i) }
          @episodes[episode][beat] = Line.new(fingerprint, timings, note)
        end
      end
      path = File.join(dir, 'words.yaml')
      return unless File.exist?(path)

      yaml = YAML.safe_load_file(path) || {}
      @word_settings = yaml['settings']&.to_s
      @words = Array(yaml['words']).map(&:to_s)
    end

    def save
      FileUtils.mkdir_p(dir)
      language = LANGUAGE_NAMES.fetch(lang, lang)
      @episodes.each do |episode, beats|
        next if beats.empty?

        rows = beats.sort.map do |beat, line|
          times = line.timings.map { |t| t ? t.join('-') : '-' }.join(' ')
          "#{beat}: #{KathaStory.scalar([line.fingerprint, times, line.note].compact.join('  ').strip)}"
        end
        write(File.join(dir, "#{episode}.yaml"), <<~HEAD + rows.join("\n"))
          # #{episode} in #{language}, as recorded. Written by tool/render_katha_audio.rb; don't edit.
          # beat: fingerprint  then when each word starts-ends, in ms ("-": not found in the audio)
        HEAD
      end
      return if @words.empty?

      rows = @words.sort.map { |form| "  - #{KathaStory.scalar(form)}" }
      write(File.join(dir, 'words.yaml'), <<~HEAD + rows.join("\n"))
        # Words in #{language} recorded on their own, for tap-to-hear. Written by
        # tool/render_katha_audio.rb; don't edit. Each is served as words/<first 10 of its SHA-1>.mp3.
        settings: #{KathaStory.scalar(word_settings)}
        words:
      HEAD
    end

    private


    def write(path, text)
      text = "#{text}\n"
      File.write(path, text) unless File.exist?(path) && File.read(path) == text
    end
  end
end
