#!/usr/bin/env ruby
# frozen_string_literal: true

# One-off: turns the generated Katha JSON (assets/katha/<series>/) into the
# YAML people edit (stories/<series>/), then compiles that YAML straight
# back and checks nothing was lost. Run once per series; after that the
# YAML is the source and tool/katha_build.rb makes the JSON.
#
#   ruby tool/katha_import.rb                 # dev-in-the-city
#   ruby tool/katha_import.rb --verify-only   # compare, write nothing
#   ruby tool/katha_import.rb --force         # overwrite stories/ (loses hand edits!)

require 'fileutils'
require 'json'
require_relative 'lib/katha_story'

include KathaStory # rubocop:disable Style/MixinUsage

series = 'dev-in-the-city'
verify_only = ARGV.delete('--verify-only')
force = ARGV.delete('--force')
src = File.join(OUTPUT, series)
out = File.join(SOURCE, series)
if Dir.exist?(out) && !verify_only && !force
  abort "#{out.sub("#{ROOT}/", '')} already exists, and is the source now: edit it, then " \
        "ruby tool/katha_build.rb. (--force rebuilds it from the JSON, losing edits.)"
end
episodes = Dir.children(src).grep(/\As\d+e\d+\z/).sort
langs = %w[kn hi]

scenes = episodes.to_h { |e| [e, JSON.parse(File.read(File.join(src, e, "#{e}.scene.json")))] }
tellings = episodes.to_h do |e|
  [e, langs.to_h { |l| [l, JSON.parse(File.read(File.join(src, e, 'tellings', "#{l}.telling.json")))] }]
end

# Cues an episode actually sets off: from its beats and its words, and
# whatever those chain on to. The rest were never reachable.
def referenced(scene, tellings)
  queue = scene['beats'].flat_map { |b| (b['on_start'] || []) + (b['on_end'] || []) } +
          tellings.values.flat_map { |t| t['beats'].values.flat_map { |l| l['tokens'].filter_map { |tk| tk['cue'] } } }
  seen = []
  while (id = queue.shift)
    next if seen.include?(id) || !scene['cues'][id]

    seen << id
    queue.concat((scene['cues'][id]['then'] || []).map { |s| s['cue'] })
  end
  seen
end

used = episodes.to_h { |e| [e, referenced(scenes[e], tellings[e])] }

# The library takes each cue's most common definition; an episode that
# times it differently keeps its own.
library = Hash.new { |h, k| h[k] = Hash.new(0) }
episodes.each { |e| used[e].each { |id| library[id][JSON.generate(scenes[e]['cues'][id])] += 1 } }
library = library.sort.to_h { |id, defs| [id, JSON.parse(defs.max_by { |d, n| [n, d] }.first)] }

cast = {}
scenes.each_value { |s| cast.merge!(s['cast']) }
names = langs.to_h do |l|
  [l, tellings.values.each_with_object({}) { |t, acc| t[l]['strings'].each { |k, v| acc[k] = v if k.start_with?('name.') } }]
end

files = {}
cue_width = library.keys.map(&:length).max
cast_width = cast.keys.map(&:length).max
files['series.yaml'] = <<~YAML
  # Dev in the City: who is in it, and the cues every episode draws on.
  # Format: stories/README.md
  #
  # A cue is "target move milliseconds", and can set off more cues after it:
  #   meter.tap: meter tap 400 -> meter.broken 300, raju.laugh 800
  # An episode that needs a cue timed differently redefines it in its own
  # episode.yaml.

  cast:
  #{cast.map { |id, c| "  #{"#{id}:".ljust(cast_width + 1)} #{flow(c)}" }.join("\n")}

  cues:
  #{library.map { |id, c| "  #{"#{id}:".ljust(cue_width + 1)} #{scalar(format_cue(c))}" }.join("\n")}
YAML

LANGUAGE = { 'kn' => 'Kannada', 'hi' => 'Hindi' }.freeze
langs.each do |l|
  width = names[l].keys.map { |k| k.length - 5 }.max
  files["#{l}.yaml"] = <<~YAML
    # Every character's name in #{LANGUAGE[l]}: native | roman | English
    # (the English is left off when it is the roman again).

    names:
    #{names[l].map { |k, v| "  #{"#{k.delete_prefix('name.')}:".ljust(width + 1)} #{scalar(format_string(v))}" }.join("\n")}
  YAML
end

def beat_yaml(beat)
  spec = { 'who' => beat['speaker'] }
  spec['mood'] = beat['delivery'] if beat['delivery']
  spec['icons'] = beat.dig('bubble', 'icons') if beat.dig('bubble', 'icons')
  spec['digits'] = beat.dig('bubble', 'digits') if beat.dig('bubble', 'digits')
  spec['tags'] = beat['tags'] if beat['tags']
  spec['start'] = beat['on_start'] unless beat['on_start'].empty?
  spec['end'] = beat['on_end'] if beat['on_end']
  spec['cliffhanger'] = true if beat['cliffhanger']
  spec.keys == ['who'] ? scalar(beat['speaker']) : flow(spec)
end

episodes.each do |e|
  scene = scenes[e]
  dir = e
  english = tellings[e]['kn']['strings'][scene['title_key']]&.dig('g')

  meta = []
  meta << "# #{e}: #{english}" << '# Format: stories/README.md' << ''
  meta << "level: #{scene['level_hint']}"
  meta << "next: #{scene['next_tease_key'].delete_suffix('.tease')}" if scene['next_tease_key']
  pv = scene['preview']
  camera = pv['camera'].map { |c| [c['at'], c['x'], c['zoom']] }
  meta << "preview: #{flow({ 'panel' => pv['panel'], 'ms' => pv['duration_ms'], 'camera' => camera })}"
  memento = scene['memento']
  if memento && memento == { 'id' => "m.#{e}", 'asset' => "memento.#{e}", 'replays_beat' => memento['replays_beat'] }
    meta << "memento: #{memento['replays_beat']}"
  elsif memento
    meta << "memento: #{flow(memento)}"
  end
  meta << "steal: #{scene['steal_this_line_beat']}" if scene['steal_this_line_beat'] != memento&.dig('replays_beat')
  ps = scene['panels'].map { |p| p['id'] }
  default_gist = {
    'type' => 'order',
    'cards' => ps.each_with_index.map { |p, i| { 'id' => "g#{i + 1}", 'panel' => p } },
    'answer' => ps.each_index.map { |i| "g#{i + 1}" }
  }
  meta << "gist: #{flow(scene['gist_cards'])}" unless scene['gist_cards'] == default_gist
  overrides = used[e].select { |id| scene['cues'][id] != library[id] }
  unless overrides.empty?
    meta << '' << '# Cues timed differently from series.yaml in this episode.' << 'cues:'
    w = overrides.map(&:length).max
    overrides.each { |id| meta << "  #{"#{id}:".ljust(w + 1)} #{scalar(format_cue(scene['cues'][id]))}" }
  end
  files["#{dir}/episode.yaml"] = "#{meta.join("\n")}\n"

  script = ["# #{e}: #{english}. Who is where, and what happens, beat by beat.", '# Format: stories/README.md']
  scene['panels'].each do |panel|
    set = panel['background'].delete_prefix('bg.')
    script << '' << "#{panel['id']}:" << "  set: #{scalar(set)}"
    ambient = panel['ambient'].delete_prefix('amb.')
    script << "  ambient: #{scalar(ambient)}" unless ambient == set
    script << "  layers: #{flow(panel['layers'])}" unless panel['layers'].empty?
    unless panel['characters'].empty?
      w = panel['characters'].map { |c| c['id'].length }.max
      script << '  cast:'
      panel['characters'].each do |c|
        raise "#{e} #{c['id']}: rig #{c['rig']}" unless c['rig'] == "char.#{c['id']}"

        script << "    #{"#{c['id']}:".ljust(w + 1)} #{scalar("#{c['pose']} @ #{c['x']}")}"
      end
    end
    props = panel['props'] || []
    unless props.empty?
      w = props.map { |p| p['id'].length }.max
      script << '  props:'
      props.each do |p|
        raise "#{e} #{p['id']}: asset #{p['asset']}" unless p['asset'].start_with?('prop.')

        text = p['asset'].delete_prefix('prop.')
        text += " on #{p['attach']}" if p['attach']
        script << "    #{"#{p['id']}:".ljust(w + 1)} #{scalar(text)}"
      end
    end
    script << "  signboards: #{flow(panel['signboards'])}" if panel['signboards']
    script << '  beats:'
    scene['beats'].select { |b| b['panel'] == panel['id'] }.each do |b|
      script << "    #{b['id']}: #{beat_yaml(b)}"
    end
  end
  files["#{dir}/script.yaml"] = "#{script.join("\n")}\n"

  langs.each do |l|
    t = tellings[e][l]
    lines = ["# #{e} in #{LANGUAGE[l]}. Each word of a line, one per row:",
             '#   roman[:FN]  [part·part:FN]  [< lemma]  "gloss"  [@cue] [loan] [name] [=native]',
             '# Format: stories/README.md', '']
    strings = t['strings'].dup
    title = strings.delete(scene['title_key'])
    tease = strings.delete(scene['next_tease_key'])
    strings.reject! { |k, _| k.start_with?('name.') }
    lines << "title: #{scalar(format_string(title))}" if title
    lines << "tease: #{scalar(format_string(tease))}" if tease
    lines << "level: #{t['level']}" unless t['level'] == scene['level_hint']
    unless strings.empty?
      lines << 'strings:'
      strings.each { |k, v| lines << "  #{k}: #{scalar(format_string(v))}" }
    end
    scene['beats'].each do |b|
      line = t['beats'][b['id']]
      natives = line['tokens'].map { |tk| tk['n'] }
      explicit = sentence_words(line['n']) != natives
      lines << '' << "#{b['id']}:"
      lines << "  say: #{scalar(line['n'])}"
      lines << "  en: #{scalar(line['tr'])}"
      probe = line['tokens'].map { |tk| tk.except('t') }
      lines << "  chunks: #{flow(line['chunks'].map(&:size))}" unless default_chunks(line['n'], probe) == line['chunks']
      lines << '  words: |'
      format_words(line['tokens'], explicit).each { |row| lines << "    #{row}" }
    end
    files["#{dir}/#{l}.yaml"] = "#{lines.join("\n")}\n"
  end
end

# ------------------------------------------------------------------ write

if verify_only
  # Compile from a scratch copy so the real stories/ is untouched.
  require 'tmpdir'
  scratch = Dir.mktmpdir('katha-import-')
  out = File.join(scratch, series)
  KathaStory.send(:remove_const, :SOURCE)
  KathaStory.const_set(:SOURCE, scratch)
end
files.each do |rel, text|
  path = File.join(out, rel)
  FileUtils.mkdir_p(File.dirname(path))
  File.write(path, text)
end

# ------------------------------------------------------------------ verify

def diff(a, b, path = '', acc = [])
  if a.is_a?(Hash) && b.is_a?(Hash)
    (a.keys | b.keys).each { |k| diff(a[k], b[k], "#{path}.#{k}", acc) }
  elsif a.is_a?(Array) && b.is_a?(Array) && a.size == b.size
    a.each_index { |i| diff(a[i], b[i], "#{path}[#{i}]", acc) }
  elsif a != b
    acc << "#{path}: #{JSON.generate(a)[0, 120]}  ->  #{JSON.generate(b)[0, 120]}"
  end
  acc
end

loaded = KathaStory::Series.load(series)
problems = []
warnings = []
episodes.each do |e|
  compiled = KathaStory.compile(loaded, e, warnings)
  before = scenes[e].dup
  before['cues'] = before['cues'].slice(*used[e])
  before['panels'] = before['panels'].map { |p| { 'props' => [] }.merge(p) }
  after = compiled[:scene].merge('cast' => compiled[:scene]['cast'].slice(*before['cast'].keys))
  problems.concat(diff(before, after).map { |d| "#{e} scene#{d}" })
  langs.each do |l|
    was = tellings[e][l]
    now = compiled[:tellings][l]
    now = now.merge('strings' => now['strings'].slice(*was['strings'].keys))
    extra = compiled[:tellings][l]['strings'].keys - was['strings'].keys
    problems << "#{e}/#{l} extra strings #{extra}" unless extra.all? { |k| k.start_with?('name.') }
    problems.concat(diff(was, now).map { |d| "#{e}/#{l}#{d}" })
  end
end

lines_before = Dir[File.join(src, 's*', '**', '*.json')].sum { |f| JSON.pretty_generate(JSON.parse(File.read(f))).lines.size }
lines_after = files.values.sum { |t| t.lines.size }
puts "#{files.size} YAML files, #{lines_after} lines (the JSON pretty-printed is #{lines_before})"
puts "#{warnings.size} warnings" unless warnings.empty?
warnings.first(10).each { |w| puts "  warn #{w}" }
if problems.empty?
  puts "round trip: all #{episodes.size} episodes compile back to the same scene and tellings"
else
  puts "round trip: #{problems.size} differences"
  problems.first(40).each { |p| puts "  #{p}" }
  exit 1
end
