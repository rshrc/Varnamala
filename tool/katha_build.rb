#!/usr/bin/env ruby
# frozen_string_literal: true

# Compiles Katha stories from the YAML people edit (stories/<series>/) into
# the compact JSON the app loads (assets/katha/<series>/). The JSON is not
# in git: run this after editing a story, and before building the app.
#
#   ruby tool/katha_build.rb                  # every series, every episode
#   ruby tool/katha_build.rb s2e03 s2e04      # just these
#   ruby tool/katha_build.rb --check          # exit 1 if the JSON is out of date
#
# Writes only files whose content changed. Format: stories/README.md

require_relative 'lib/katha_story'

check = ARGV.delete('--check')
only = ARGV.empty? ? nil : ARGV
warnings = []
stale = []
begin
  KathaStory.series_list.each do |series|
    episodes = only ? only & KathaStory.episodes(series) : nil
    next if episodes&.empty?

    stale.concat(KathaStory.build(series, episodes, check: check, warnings: warnings))
  end
rescue KathaStory::Error => e
  abort "katha_build: #{e.message}"
end
unknown = only ? only - KathaStory.series_list.flat_map { |s| KathaStory.episodes(s) } : []
abort "katha_build: no episode #{unknown.join(', ')} in stories/" unless unknown.empty?

warnings.each { |w| warn "  warn #{w}" }
relative = stale.map { |p| p.sub("#{KathaStory::ROOT}/", '') }
if check
  if relative.empty?
    puts 'Katha JSON is up to date.'
  else
    warn "#{relative.size} Katha files out of date; run ruby tool/katha_build.rb:"
    relative.first(10).each { |p| warn "  #{p}" }
    exit 1
  end
else
  puts relative.empty? ? 'Katha JSON already up to date.' : "wrote #{relative.size} files"
end
