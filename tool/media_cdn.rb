#!/usr/bin/env ruby
# frozen_string_literal: true

# Varnamala's demo videos and images, served from their own Cloudflare Pages
# project (varnamala-media), so the README can show them without putting
# megabytes of video in git.
#
#   ruby tool/media_cdn.rb status    # what is listed, here, and live
#   ruby tool/media_cdn.rb push      # upload media/ (only changed files go up)
#   ruby tool/media_cdn.rb pull      # download listed files this checkout lacks
#
# media/index.yaml (in git) lists the files; the files themselves are not in
# git. Credentials as for tool/katha_cdn.rb: CLOUDFLARE_API_TOKEN and
# CLOUDFLARE_ACCOUNT_ID in the environment.

require 'fileutils'
require 'net/http'
require 'tmpdir'
require 'yaml'
require_relative 'lib/cloudflare_pages'

ROOT = File.expand_path('..', __dir__)
MEDIA = File.join(ROOT, 'media')
PROJECT = 'varnamala-media'

# Videos are kept a week and revalidated in the background; a re-cut demo
# under the same name reaches readers within a week at most. Give a new cut
# a new name if it must show at once.
HEADERS = <<~HEADERS
  /*
    Access-Control-Allow-Origin: *
    Cache-Control: public, max-age=604800, stale-while-revalidate=2592000
    X-Content-Type-Options: nosniff
HEADERS

def listed = YAML.safe_load_file(File.join(MEDIA, 'index.yaml')).fetch('files').keys
def here?(name) = File.exist?(File.join(MEDIA, name))
def site(project) = "https://#{project['subdomain'] || "#{PROJECT}.pages.dev"}/"

def size(bytes) = bytes >= 1_048_576 ? format('%.1f MB', bytes / 1_048_576.0) : format('%d KB', bytes / 1024)

def status(pages)
  project = pages.project(PROJECT)
  puts project ? "live  #{site(project)}" : "live  not created yet (ruby tool/media_cdn.rb push)"
  listed.each do |name|
    local = here?(name) ? size(File.size(File.join(MEDIA, name))) : 'missing here'
    puts "  #{name.ljust(32)} #{local}"
  end
end

def pull(pages)
  project = pages.project(PROJECT) or abort 'nothing live to pull from'
  listed.reject { |name| here?(name) }.each do |name|
    res = Net::HTTP.get_response(URI("#{site(project)}#{name}"))
    abort "#{name}: HTTP #{res.code} from the live site" unless res.code == '200'
    File.binwrite(File.join(MEDIA, name), res.body)
    puts "pulled #{name}"
  end
end

def push(pages)
  missing = listed.reject { |name| here?(name) }
  unless missing.empty?
    abort "missing #{missing.join(', ')}: run pull first, or drop them from media/index.yaml " \
          '(a push replaces the whole site)'
  end
  project = pages.ensure_project(PROJECT)
  Dir.mktmpdir('varnamala-media-') do |dir|
    listed.each { |name| FileUtils.cp(File.join(MEDIA, name), File.join(dir, name)) }
    File.write(File.join(dir, '_headers'), HEADERS)
    pages.deploy(PROJECT, dir, message: 'media')
  end
  listed.each do |name|
    uri = URI("#{site(project)}#{name}")
    res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.head(uri.path) }
    puts "  #{res.code == '200' ? 'ok ' : 'BAD'}  #{uri}  (#{res['content-type']})"
  end
end

begin
  pages = CloudflarePages.from_env
  case ARGV.first
  when 'status' then status(pages)
  when 'pull' then pull(pages)
  when 'push' then push(pages)
  else abort 'usage: ruby tool/media_cdn.rb status|push|pull'
  end
rescue CloudflarePages::Error => e
  abort e.message
end
