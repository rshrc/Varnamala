#!/usr/bin/env ruby
# frozen_string_literal: true

# Katha's recordings, served from Cloudflare Pages: one project per language
# (katha-audio-kn, katha-audio-hi, ...), free, with no bandwidth limit.
#
#   source ~/.katha/cloudflare.env       # CLOUDFLARE_API_TOKEN, CLOUDFLARE_ACCOUNT_ID
#
#   ruby tool/katha_cdn.rb status              # what is live, per language
#   ruby tool/katha_cdn.rb plan kn             # what a push would send, nothing uploaded
#   ruby tool/katha_cdn.rb push                # every language: create if needed, upload changes
#   ruby tool/katha_cdn.rb push kn --message "s2e03 re-recorded"
#   ruby tool/katha_cdn.rb verify hi           # fetch a sample from the live site and check it
#   ruby tool/katha_cdn.rb pull                # download recordings this checkout lacks
#
# The MP3s are not in git. stories/<series>/recordings/<lang>/ is: it says
# which recordings exist, and `pull` fetches any a fresh checkout lacks from
# the live site. The app's word index (words/index.json) is generated from it
# at push time.
#
# A push stages one language's folder (assets/katha/<series>/audio/<lang>/)
# with a _headers file, then hands it to Wrangler, which uploads only the files
# Cloudflare has not seen. Re-recording five lines and pushing sends five files.
# A deployment is the whole site, so a push first pulls anything the indexes
# list but this checkout lacks, and refuses to go ahead if it still cannot:
# pushing an incomplete folder would delete those files from the live site.
#
# What the live site holds, per language, at https://<project>.pages.dev/:
#   <episode>-<beat>.mp3     a line          (the telling's "audio/<lang>/..." minus the prefix)
#   words/<hash>.mp3         a single word
#   words/index.json         word -> file, which the app reads

require 'fileutils'
require 'json'
require 'net/http'
require 'optparse'
require 'tmpdir'
require 'uri'
require_relative 'lib/cloudflare_pages'
require_relative 'lib/katha_story'

ROOT = File.expand_path('..', __dir__)
SERIES = 'dev-in-the-city'
SERIES_DIR = File.join(ROOT, 'assets', 'katha', SERIES)

# Browsers keep a recording for a day and may use it for a week while they
# check for a newer one in the background: a re-recorded line reaches
# everyone within a day, and nobody waits on the network to hear a line twice.
# The word index is small and changes when words are added, so it is kept
# fresher.
HEADERS = <<~HEADERS
  /*
    Access-Control-Allow-Origin: *
    Cache-Control: public, max-age=86400, stale-while-revalidate=604800
    X-Content-Type-Options: nosniff
  /words/index.json
    Cache-Control: public, max-age=300, stale-while-revalidate=86400
HEADERS

module KathaCdn
  module_function

  def project_name(lang) = "katha-audio-#{lang}"

  def languages = KathaStory::Voices.load(SERIES).languages

  # Where this checkout keeps a language's MP3s (not in git).
  def source_dir(lang) = File.join(SERIES_DIR, 'audio', lang)

  def recordings(lang) = KathaStory::Recordings.load(SERIES, lang)

  # Every recording the site should serve, from stories/<series>/recordings/.
  def expected(lang) = recordings(lang).files.sort

  def missing(lang) = expected(lang).reject { |path| File.exist?(File.join(source_dir(lang), path)) }

  # Copies (by hard link, so it costs nothing) a language's recordings into a
  # fresh folder, with the app's word index and the _headers file, and
  # yields it. Only recordings the stories list go up: a stray local file
  # does not.
  def stage(lang)
    Dir.mktmpdir("katha-#{lang}-") do |dir|
      expected(lang).each do |path|
        target = File.join(dir, path)
        FileUtils.mkdir_p(File.dirname(target))
        source = File.join(source_dir(lang), path)
        begin
          File.link(source, target)
        rescue SystemCallError
          FileUtils.cp(source, target)
        end
      end
      FileUtils.mkdir_p(File.join(dir, 'words'))
      File.write(File.join(dir, 'words', 'index.json'), JSON.generate(recordings(lang).word_index))
      File.write(File.join(dir, '_headers'), HEADERS)
      yield dir
    end
  end

  # Downloads [paths] from [base] into the language's folder, a few at a
  # time. Returns the ones that could not be fetched.
  def download(lang, base, paths, threads: 8)
    queue = Queue.new
    paths.each { |path| queue << path }
    failed = Queue.new
    done = 0
    lock = Mutex.new
    Array.new(threads) do
      Thread.new do
        while (path = begin; queue.pop(true); rescue ThreadError; nil; end)
          res = begin; fetch("#{base}#{path}"); rescue StandardError; nil; end
          if res&.code == '200'
            target = File.join(source_dir(lang), path)
            FileUtils.mkdir_p(File.dirname(target))
            File.binwrite(target, res.body)
          else
            failed << path
          end
          lock.synchronize do
            done += 1
            print "\r    #{done}/#{paths.size}" if (done % 25).zero? || done == paths.size
          end
        end
      end
    end.each(&:join)
    puts unless paths.empty?
    Array.new(failed.size) { failed.pop }
  end

  def human_size(bytes)
    units = %w[B KB MB GB]
    size = bytes.to_f
    unit = units.shift
    while size >= 1024 && units.any?
      size /= 1024
      unit = units.shift
    end
    format('%.1f %s', size, unit)
  end

  def local_summary(lang)
    paths = expected(lang).select { |path| File.exist?(File.join(source_dir(lang), path)) }
    bytes = paths.sum { |path| File.size(File.join(source_dir(lang), path)) }
    lines = paths.count { |path| !path.start_with?('words/') && path.end_with?('.mp3') }
    words = paths.count { |path| path.start_with?('words/') && path.end_with?('.mp3') }
    { files: paths.size, lines: lines, words: words, bytes: bytes }
  end

  # The site's address: Cloudflare normally uses the project name, but adds a
  # suffix when that name is already taken elsewhere on pages.dev.
  def site(project)
    "https://#{project['subdomain'] || "#{project['name']}.pages.dev"}/"
  end

  def fetch(url, method: Net::HTTP::Get)
    uri = URI(url)
    Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 10, read_timeout: 30) do |http|
      http.request(method.new(uri))
    end
  end
end

# ------------------------------------------------------------------ commands

def status(pages, langs)
  live = pages.projects
  langs.each do |lang|
    name = KathaCdn.project_name(lang)
    local = KathaCdn.local_summary(lang)
    puts "#{lang}  #{name}"
    puts "    local   #{local[:lines]} lines, #{local[:words]} words, #{KathaCdn.human_size(local[:bytes])}"
    gap = KathaCdn.missing(lang).size
    puts "    missing #{gap} files the indexes list: ruby tool/katha_cdn.rb pull #{lang}" if gap.positive?
    project = live[name]
    unless project
      puts '    live    not created yet: ruby tool/katha_cdn.rb push ' + lang
      next
    end
    deployment = pages.latest_deployment(name)
    when_ = deployment ? deployment['created_on'] : 'never deployed'
    puts "    live    #{KathaCdn.site(project)}  (last push #{when_})"
  end
end

def plan(langs)
  langs.each do |lang|
    local = KathaCdn.local_summary(lang)
    puts "#{lang}: would stage #{local[:files]} files (#{local[:lines]} lines, #{local[:words]} words, " \
         "#{KathaCdn.human_size(local[:bytes])}) plus _headers for #{KathaCdn.project_name(lang)}."
    puts '    Wrangler then uploads only the files the project does not already have.'
  end
end

# Fetches every recording the indexes list but this checkout lacks.
# Returns false if some could not be found on the live site either.
def pull(pages, langs)
  live = pages.projects
  langs.all? do |lang|
    gap = KathaCdn.missing(lang)
    project = live[KathaCdn.project_name(lang)]
    if gap.empty?
      puts "#{lang}: nothing to pull"
      next true
    end
    unless project
      warn "#{lang}: #{gap.size} files missing and no live site to pull them from"
      next false
    end
    puts "#{lang}: pulling #{gap.size} files from #{KathaCdn.site(project)}"
    failed = KathaCdn.download(lang, KathaCdn.site(project), gap)
    failed.first(10).each { |path| warn "    not on the live site either: #{path}" }
    failed.empty?
  end
end

def push(pages, langs, message)
  langs.each do |lang|
    name = KathaCdn.project_name(lang)
    if KathaCdn.local_summary(lang)[:files].zero? && KathaCdn.expected(lang).empty?
      warn "#{lang}: nothing recorded, skipped"
      next
    end
    unless KathaCdn.missing(lang).empty? || pull(pages, [lang])
      abort "#{lang}: not pushing: this checkout lacks recordings the live site has, " \
            'and a push would delete them. Re-record them, or drop them from the index.'
    end
    local = KathaCdn.local_summary(lang)
    project = pages.ensure_project(name)
    puts "#{lang}: pushing #{local[:files]} files to #{KathaCdn.site(project)}"
    KathaCdn.stage(lang) { |dir| pages.deploy(name, dir, message: message) }
    verify(pages, [lang])
  end
end

# Fetches the word index and a sample of recordings from the live site and
# checks each arrives whole, as audio, with the headers the app relies on.
def verify(pages, langs)
  live = pages.projects
  ok = true
  langs.each do |lang|
    project = live[KathaCdn.project_name(lang)]
    unless project
      warn "#{lang}: no project yet"
      ok = false
      next
    end
    base = KathaCdn.site(project)
    index = KathaCdn.fetch("#{base}words/index.json")
    words = index.code == '200' ? JSON.parse(index.body).fetch('words', {}) : {}
    checks = [['words/index.json', index, 'application/json']]
    problems = []
    problems << 'live word index differs from the recordings' unless words == KathaCdn.recordings(lang).word_index['words']
    sample = KathaCdn.expected(lang).sample(6, random: Random.new(lang.sum))
    sample.each { |path| checks << [path, KathaCdn.fetch("#{base}#{path}"), 'audio/mpeg'] }
    checks.each do |path, res, type|
      local = File.join(KathaCdn.source_dir(lang), path)
      problems = []
      problems << "HTTP #{res.code}" unless res.code == '200'
      problems << "type #{res['content-type']}" unless res['content-type'].to_s.start_with?(type)
      problems << 'no CORS header' unless res['access-control-allow-origin'] == '*'
      if path.end_with?('.mp3') && File.exist?(local) && res.body.bytesize != File.size(local)
        problems << "#{res.body.bytesize} bytes, expected #{File.size(local)}"
      end
      ok &&= problems.empty?
      puts "    #{problems.empty? ? 'ok ' : 'BAD'}  #{path}#{problems.empty? ? '' : "  (#{problems.join(', ')})"}"
    end
    puts "    #{words.size} words in the live index#{problems.empty? ? '' : "  BAD: #{problems.join(', ')}"}"
    ok &&= problems.empty?
  end
  exit 1 unless ok
end

# ------------------------------------------------------------------ main

message = nil
parser = OptionParser.new do |o|
  o.banner = 'usage: ruby tool/katha_cdn.rb status|plan|push|pull|verify [lang ...] [--message TEXT]'
  o.on('--message TEXT', 'note shown on the Cloudflare deployment') { |v| message = v }
end
args = parser.parse(ARGV)
command = args.shift or abort parser.banner
langs = args.empty? ? KathaCdn.languages : args
unknown = langs - KathaCdn.languages
abort "unknown language: #{unknown.join(', ')} (known: #{KathaCdn.languages.join(', ')})" unless unknown.empty?

begin
  case command
  when 'plan' then plan(langs)
  when 'status' then status(CloudflarePages.from_env, langs)
  when 'push' then push(CloudflarePages.from_env, langs, message)
  when 'verify' then verify(CloudflarePages.from_env, langs)
  when 'pull' then exit(pull(CloudflarePages.from_env, langs) ? 0 : 1)
  else abort parser.banner
  end
rescue CloudflarePages::Error => e
  abort e.message
end
