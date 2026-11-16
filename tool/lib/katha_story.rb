# frozen_string_literal: true

require 'fileutils'
require 'json'
require 'yaml'
require_relative 'katha_recordings'

# Katha stories as people write them, and as the app reads them.
#
#   stories/<series>/            what you edit (YAML, in git)
#   assets/katha/<series>/       what the app loads (compact JSON, generated, not in git)
#
# The format is described in stories/README.md. In short, everything the
# app needs that can be worked out is worked out here instead of written
# down: recording paths and word timings come from the recorder's index,
# a word's native spelling from its sentence, a line's chunks from its
# sentences, a panel's ambience from its set, a cue from the series library.
module KathaStory
  ROOT = File.expand_path('../..', __dir__)
  SOURCE = File.join(ROOT, 'stories')
  OUTPUT = File.join(ROOT, 'assets', 'katha')

  # ISO 15924 script per telling language.
  SCRIPTS = {
    'as' => 'Beng', 'bn' => 'Beng', 'gu' => 'Gujr', 'hi' => 'Deva', 'kn' => 'Knda',
    'ml' => 'Mlym', 'mr' => 'Deva', 'ne' => 'Deva', 'or' => 'Orya', 'sa' => 'Deva',
    'ta' => 'Taml', 'te' => 'Telu', 'ur' => 'Arab'
  }.freeze

  # Stripped from a sentence's words to get each word's native spelling.
  # Must match kathaWordKey in lib/courses/katha/katha_repository.dart.
  PUNCTUATION = /[.,!?;:।॥۔،؟…"“”‘’]/
  SENTENCE_END = /\A['"]?[.!?।॥]/
  REVIEW = { 'status' => 'beta', 'reviewers' => [] }.freeze
  BEAT_KEYS = %w[who mood icons digits tags start end cliffhanger].freeze
  LINE_KEYS = %w[say en words chunks].freeze

  # A problem in a source file, named so it can be found: the file, and the
  # beat or panel inside it.
  class Error < StandardError
    def initialize(file, where, message)
      super("#{file.sub("#{ROOT}/", '')}#{where ? " #{where}" : ''}: #{message}")
    end
  end

  module_function

  def episodes(series)
    Dir.children(File.join(SOURCE, series)).grep(/\As\d+e\d+\z/).sort
  end

  def series_list = Dir.children(SOURCE).select { |d| File.exist?(File.join(SOURCE, d, 'series.yaml')) }.sort

  def load_yaml(path)
    raise Error.new(path, nil, 'missing') unless File.exist?(path)

    YAML.safe_load_file(path) || {}
  rescue Psych::SyntaxError => e
    raise Error.new(path, nil, e.message)
  end

  # ================================================================ series

  # What every episode of a series shares: who is in it, how each cue
  # moves, and every character's name in each language.
  Series = Struct.new(:name, :dir, :cast, :cues, :names, :recordings, :voices) do
    def self.load(name)
      dir = File.join(SOURCE, name)
      file = File.join(dir, 'series.yaml')
      yaml = KathaStory.load_yaml(file)
      cues = (yaml['cues'] || {}).to_h { |id, text| [id, KathaStory.parse_cue(text, file, id)] }
      names = {}
      Dir[File.join(dir, '*.yaml')].each do |path|
        lang = File.basename(path, '.yaml')
        next unless SCRIPTS.key?(lang)

        names[lang] = (KathaStory.load_yaml(path)['names'] || {}).to_h do |id, text|
          ["name.#{id}", KathaStory.parse_string(text, path, "names.#{id}")]
        end
      end
      recordings = Hash.new { |h, lang| h[lang] = Recordings.load(name, lang) }
      new(name, dir, yaml.fetch('cast', {}), cues, names, recordings, Voices.load(name))
    end

    def languages = names.keys.sort
  end

  # ================================================================ small formats

  # "ದೇವ್ | Dev | Dev": native, roman, English. A roman that is also the
  # English is written once: "ದೇವ್ | Dev".
  def parse_string(text, file, where)
    parts = text.to_s.split(' | ', -1)
    raise Error.new(file, where, "expected 'native | roman | English', got #{text.inspect}") unless [2, 3].include?(parts.size)

    { 'n' => parts[0], 'r' => parts[1], 'g' => parts[2] || parts[1] }
  end

  def format_string(string)
    parts = [string['n'], string['r']]
    parts << string['g'] unless string['g'] == string['r']
    parts.join(' | ')
  end

  # "raju laugh 700" or "meter tap 400 -> meter.broken 300, raju.laugh 800":
  # target, move, milliseconds, and the cues it sets off and after how long.
  # A sound to play with it goes after the milliseconds: "dev bag_drop 500 sfx.thud".
  def parse_cue(text, file, where)
    head, chain = text.to_s.split(' -> ', 2)
    target, anim, ms, sfx, *extra = head.split
    unless ms&.match?(/\A\d+\z/) && extra.empty? && (sfx.nil? || sfx.start_with?('sfx.'))
      raise Error.new(file, where, "expected 'target move ms [sfx.sound]', got #{text.inspect}")
    end

    cue = { 'target' => target, 'anim' => anim, 'ms' => ms.to_i }
    cue['sfx'] = sfx if sfx
    if chain
      cue['then'] = chain.split(',').map do |step|
        id, after = step.split
        raise Error.new(file, where, "bad step #{step.strip.inspect}") unless after&.match?(/\A\d+\z/)

        { 'cue' => id, 'after' => after.to_i }
      end
    end
    cue
  end

  def format_cue(cue)
    text = "#{cue['target']} #{cue['anim']} #{cue['ms']}"
    text += " #{cue['sfx']}" if cue['sfx']
    return text unless cue['then']

    "#{text} -> #{cue['then'].map { |s| "#{s['cue']} #{s['after']}" }.join(', ')}"
  end

  # One word of a line, on one line:
  #
  #   roman[:FN]  [part·part:FN]  [< lemma]  "gloss"  [@cue] [loan] [name] [=native]
  #
  # FN is a grammatical label (PRES.1SG). The lemma defaults to the roman
  # word in lower case without ~, and the native spelling to the matching
  # word of the sentence; either is written only where it differs.
  def parse_word(line, file, where)
    fields = line.scan(/[^\s"]*"[^"]*"|\S+/)
    roman, fn = fields.shift.split(':', 2)
    token = { 'r' => roman }
    lemma = gloss = native = morphs = nil
    flags = []
    cue = nil
    while (field = fields.shift)
      case field
      when '<'
        lemma = unquote(fields.shift || raise(Error.new(file, where, "nothing after '<' in #{line.inspect}")))
      when /\A".*"\z/ then gloss = field[1..-2]
      when /\A@(.+)/ then cue = Regexp.last_match(1)
      when 'loan', 'name' then flags << field
      when /\A=(.+)/ then native = unquote(Regexp.last_match(1))
      when /·/
        morphs = field.split('·').reject(&:empty?).map do |part|
          r, part_fn = part.split(':', 2)
          part_fn ? { 'r' => r, 'fn' => part_fn } : { 'r' => r }
        end
      else
        raise Error.new(file, where, "don't know #{field.inspect} in #{line.inspect}")
      end
    end
    raise Error.new(file, where, "no \"gloss\" in #{line.inspect}") unless gloss

    token['n'] = native if native
    token['l'] = lemma || default_lemma(roman)
    token['g'] = gloss
    token['m'] = morphs if morphs
    token['fn'] = fn if fn
    token['cue'] = cue if cue
    token['loan'] = true if flags.include?('loan')
    token['name'] = true if flags.include?('name')
    token
  end

  def unquote(text) = text.start_with?('"') && text.end_with?('"') ? text[1..-2] : text

  def default_lemma(roman) = roman.downcase.delete('~')

  # A line's words as an aligned block, one word per line.
  def format_words(tokens, with_native)
    rows = tokens.map do |token|
      head = token['fn'] ? "#{token['r']}:#{token['fn']}" : token['r']
      parts = token['m'] ? token['m'].map { |m| m['fn'] ? "#{m['r']}:#{m['fn']}" : m['r'] }.join('·') : ''
      parts = "·#{parts}" if token['m']&.size == 1
      lemma = token['l'] == default_lemma(token['r']) ? '' : "< #{quote_if_spaced(token['l'])}"
      tail = ["\"#{token['g']}\""]
      tail << "@#{token['cue']}" if token['cue']
      tail << 'loan' if token['loan']
      tail << 'name' if token['name']
      tail << "=#{quote_if_spaced(token['n'])}" if with_native
      [head, parts, lemma, tail.join(' ')]
    end
    widths = (0..2).map { |i| rows.map { |row| row[i].length }.max }
    rows.map do |row|
      cells = (0..2).reject { |i| widths[i].zero? }.map { |i| row[i].ljust(widths[i]) }
      (cells + [row[3]]).join('  ').rstrip
    end
  end

  def quote_if_spaced(text) = text.match?(/\s/) ? "\"#{text}\"" : text

  # A sentence's words as the app spells them: split on spaces, punctuation
  # and quote marks dropped.
  def sentence_words(native) = native.split(/\s+/).map { |w| w.gsub(PUNCTUATION, '').delete("'") }.reject(&:empty?)

  # Groups of at most three words, never across a sentence end. The band
  # under the picture moves a chunk at a time.
  def default_chunks(native, tokens)
    sentences = [[]]
    cursor = 0
    tokens.each_with_index do |token, i|
      at = native.index(token['n'], cursor) or return nil
      cursor = at + token['n'].length
      sentences.last << i
      sentences << [] if native[cursor..].match?(SENTENCE_END) && i < tokens.size - 1
    end
    sentences.reject(&:empty?).flat_map do |sentence|
      n = (sentence.size / 3.0).ceil
      sentence.each_slice((sentence.size / n.to_f).ceil).to_a
    end
  end

  # ================================================================ compile

  # One episode, compiled: its scene and a telling per language, as the
  # app reads them. Warnings (a recording older than its line) are
  # collected rather than raised.
  def compile(series, episode, warnings = [])
    dir = File.join(series.dir, episode)
    meta_file = File.join(dir, 'episode.yaml')
    script_file = File.join(dir, 'script.yaml')
    meta = load_yaml(meta_file)
    script = load_yaml(script_file)

    panels = []
    beats = []
    script.each do |panel_id, spec|
      raise Error.new(script_file, panel_id, 'panels are named p1, p2, ...') unless panel_id.match?(/\Ap\d+\z/)

      panels << compile_panel(panel_id, spec, script_file)
      (spec['beats'] || {}).each do |beat_id, beat|
        beats << compile_beat(beat_id, panel_id, beat, script_file, series)
      end
    end
    raise Error.new(script_file, nil, 'no beats') if beats.empty?

    tellings = series.languages.to_h do |lang|
      [lang, compile_telling(series, episode, lang, meta, beats, warnings)]
    end

    used = beats.flat_map { |b| b['on_start'] + (b['on_end'] || []) } +
           tellings.values.flat_map { |t| t['beats'].values.flat_map { |l| l['tokens'].filter_map { |tk| tk['cue'] } } }
    cues = {}
    queue = used.uniq
    while (id = queue.shift)
      next if cues.key?(id)

      text = meta.dig('cues', id)
      cue = text ? parse_cue(text, meta_file, "cues.#{id}") : series.cues[id]
      raise Error.new(script_file, nil, "cue #{id} is not in episode.yaml or series.yaml") unless cue

      cues[id] = cue
      queue.concat((cue['then'] || []).map { |step| step['cue'] })
    end

    memento = meta['memento']
    memento = { 'id' => "m.#{episode}", 'asset' => "memento.#{episode}", 'replays_beat' => memento } if memento.is_a?(String)
    preview = meta['preview'] or raise Error.new(meta_file, nil, 'no preview')
    preview_panel = panels.find { |p| p['id'] == preview['panel'] } or
      raise Error.new(meta_file, 'preview', "no panel #{preview['panel']}")

    scene = {
      '$schema' => '../schema/scene.schema.json',
      'id' => episode,
      'series' => series.name,
      'title_key' => "#{episode}.title",
      'level_hint' => meta.fetch('level'),
      'preview' => {
        'panel' => preview['panel'],
        'duration_ms' => preview.fetch('ms'),
        'camera' => preview.fetch('camera').map { |at, x, zoom| { 'at' => at, 'x' => x, 'zoom' => zoom } },
        'ambient' => preview_panel['ambient']
      },
      'panels' => panels,
      'cast' => series.cast,
      'cues' => cues,
      'beats' => beats,
      'gist_cards' => meta['gist'] || {
        'type' => 'order',
        'cards' => panels.each_with_index.map { |p, i| { 'id' => "g#{i + 1}", 'panel' => p['id'] } },
        'answer' => panels.each_index.map { |i| "g#{i + 1}" }
      },
      'memento' => memento,
      'steal_this_line_beat' => meta['steal'] || memento&.dig('replays_beat'),
      'next_tease_key' => meta['next'] && "#{meta['next']}.tease"
    }.compact
    { scene: scene, tellings: tellings }
  end

  def compile_panel(id, spec, file)
    set = spec['set'] or raise Error.new(file, id, 'no set')
    panel = {
      'id' => id,
      'background' => "bg.#{set}",
      'layers' => spec['layers'] || [],
      'characters' => (spec['cast'] || {}).map do |who, text|
        pose, x = text.to_s.split(' @ ')
        raise Error.new(file, "#{id} #{who}", "expected 'pose @ x', got #{text.inspect}") unless x

        { 'id' => who, 'rig' => "char.#{who}", 'pose' => pose, 'x' => number(x) }
      end,
      'props' => (spec['props'] || {}).map do |prop, text|
        asset, attach = text.to_s.split(' on ')
        { 'id' => prop, 'asset' => "prop.#{asset}", 'attach' => attach }.compact
      end
    }
    panel['signboards'] = spec['signboards'] if spec['signboards']
    panel['ambient'] = "amb.#{spec['ambient'] || set}"
    panel
  end

  def number(text) = text.match?(/\A-?\d+\z/) ? text.to_i : Float(text)

  def compile_beat(id, panel, spec, file, series)
    spec = { 'who' => spec } if spec.is_a?(String)
    unknown = spec.keys - BEAT_KEYS
    raise Error.new(file, id, "unknown #{unknown.join(', ')} (known: #{BEAT_KEYS.join(', ')})") unless unknown.empty?

    who = spec['who'] or raise Error.new(file, id, 'no who')
    unless who == 'narrator' || series.cast.key?(who)
      raise Error.new(file, id, "#{who} is not in series.yaml's cast")
    end

    beat = { 'id' => id, 'panel' => panel, 'speaker' => who, 'on_start' => spec['start'] || [] }
    beat['delivery'] = spec['mood'] if spec['mood']
    if spec['icons'] || spec['digits']
      beat['bubble'] = { 'icons' => spec['icons'], 'digits' => spec['digits'] }.compact
    end
    beat['tags'] = spec['tags'] if spec['tags']
    beat['on_end'] = spec['end'] if spec['end']
    beat['cliffhanger'] = true if spec['cliffhanger']
    beat
  end

  def compile_telling(series, episode, lang, meta, beats, warnings)
    file = File.join(series.dir, episode, "#{lang}.yaml")
    yaml = load_yaml(file)
    strings = series.names.fetch(lang).dup
    strings["#{episode}.title"] = parse_string(yaml['title'], file, 'title') if yaml['title']
    strings["#{meta['next']}.tease"] = parse_string(yaml['tease'], file, 'tease') if yaml['tease'] && meta['next']
    (yaml['strings'] || {}).each { |key, text| strings[key] = parse_string(text, file, "strings.#{key}") }

    known = beats.map { |b| b['id'] }
    stray = yaml.keys.grep(/\Ab\d+\z/) - known
    raise Error.new(file, stray.first, 'is not a beat in script.yaml') unless stray.empty?

    recordings = series.recordings[lang]
    lines = beats.to_h do |beat|
      id = beat['id']
      spec = yaml[id] or raise Error.new(file, id, 'missing: every beat in script.yaml needs a line here')
      line = compile_line(spec, file, id, recordings.line(episode, id), warnings, "#{episode}/#{lang} #{id}")
      if line['audio']
        line['audio'] = "audio/#{lang}/#{Recordings.line_file(episode, id)}"
        if series.voices.line_fingerprint(lang, beat, line['n']) != recordings.line(episode, id).fingerprint
          warnings << "#{episode}/#{lang} #{id}: changed since it was recorded; re-record it"
        end
      end
      [id, line]
    end

    {
      '$schema' => '../schema/telling.schema.json',
      'scene' => episode,
      'lang' => lang,
      'script' => SCRIPTS.fetch(lang),
      'level' => yaml['level'] || meta.fetch('level'),
      'review' => yaml['review'] || REVIEW,
      'strings' => strings,
      'props_swap' => {},
      'beats' => lines
    }
  end

  def compile_line(spec, file, where, recording, warnings, label)
    unknown = spec.keys - LINE_KEYS
    raise Error.new(file, where, "unknown #{unknown.join(', ')} (known: #{LINE_KEYS.join(', ')})") unless unknown.empty?

    native = spec['say'] or raise Error.new(file, where, 'no say')
    tokens = spec.fetch('words', '').to_s.lines.map(&:strip).reject(&:empty?).map do |row|
      parse_word(row, file, where)
    end
    raise Error.new(file, where, 'no words') if tokens.empty?

    if tokens.none? { |t| t['n'] }
      words = sentence_words(native)
      unless words.size == tokens.size
        raise Error.new(file, where, "#{words.size} words in the sentence, #{tokens.size} listed " \
                                     '(a word the spaces do not separate needs =native on every word)')
      end
      tokens.each_with_index { |token, i| token['n'] = words[i] }
    elsif tokens.any? { |t| !t['n'] }
      raise Error.new(file, where, 'some words have =native and some do not: give it on all or none')
    end
    tokens = tokens.map { |t| t.slice('r', 'n', 'l', 'g', 'm', 'fn', 'cue', 'loan', 'name') }

    chunks =
      if spec['chunks']
        sizes = spec['chunks']
        unless sizes.sum == tokens.size
          raise Error.new(file, where, "chunks #{sizes.inspect} add up to #{sizes.sum}, not #{tokens.size}")
        end

        at = 0
        sizes.map { |n| (at...(at += n)).to_a }
      else
        default_chunks(native, tokens) or
          raise Error.new(file, where, "a word's native spelling is not in the sentence; give chunks: [sizes]")
      end

    line = { 'n' => native }
    timings = recording&.timings
    if timings && timings.size == tokens.size
      line['audio'] = true # the caller names the file
      tokens.each_with_index { |token, i| token['t'] = timings[i] if timings[i] }
    elsif recording
      warnings << "#{label}: recording has #{timings.size} words, the line #{tokens.size}; using the device voice"
    end
    line['chunks'] = chunks
    line['tokens'] = tokens
    line['tr'] = spec['en'] or raise Error.new(file, where, 'no en')
    line
  end

  # Compiles [episodes] and writes what changed. Returns the paths written.
  def build(series_name, only = nil, check: false, warnings: [])
    series = Series.load(series_name)
    stale = []
    (only || episodes(series_name)).each do |episode|
      compiled = compile(series, episode, warnings)
      out = File.join(OUTPUT, series_name, episode)
      files = { File.join(out, "#{episode}.scene.json") => compiled[:scene] }
      compiled[:tellings].each { |lang, telling| files[File.join(out, 'tellings', "#{lang}.telling.json")] = telling }
      files.each do |path, data|
        text = "#{JSON.generate(data)}\n"
        next if File.exist?(path) && File.read(path) == text

        stale << path
        next if check

        FileUtils.mkdir_p(File.dirname(path))
        File.write(path, text)
      end
    end
    stale
  end

  # ================================================================ YAML writing

  # A scalar YAML reads back as the same string: plain when that works,
  # double-quoted (JSON's syntax is valid YAML) when it would not.
  def scalar(text, flow: false)
    text = text.to_s
    probe = flow ? "k: [#{text}]" : "k: #{text}"
    expected = flow ? { 'k' => [text] } : { 'k' => text }
    plain = !text.empty? && text == text.strip && YAML.safe_load(probe) == expected
    plain ? text : JSON.generate(text)
  rescue Psych::SyntaxError, Psych::DisallowedClass
    JSON.generate(text)
  end

  # A value as inline YAML: { who: dev, icons: [phone, house] }.
  def flow(value)
    case value
    when Hash then "{ #{value.map { |k, v| "#{k}: #{flow(v)}" }.join(', ')} }"
    when Array then "[#{value.map { |v| flow(v) }.join(', ')}]"
    when String then scalar(value, flow: true)
    else value.to_s
    end
  end
end
