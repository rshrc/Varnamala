#!/usr/bin/env ruby
# frozen_string_literal: true

# Finds dictionary entries whose "gloss" is just the word again:
#
#   "filter"  => "filter (coffee)"
#   "bus"     => "bus"
#   "anjali"  => "Anjali (name)"
#
# These are fine as dictionary entries — a learner reading a sentence still
# wants the tap-a-word hint telling them what a word is. They are not fine as
# **exercise** material: asking someone learning Kannada to type "filter", or to
# match "bus" with "bus", tests nothing about the language.
#
# The app already refuses to build questions from them (see
# `glossTeachesNothing` in lib/courses/word_dictionary.dart). This tool is for
# content review: it shows how much of a language's dictionary is loanwords,
# names and place names, so an author can judge whether a deck has enough real
# vocabulary left to teach from.
#
# Usage:
#   ruby tool/find_untranslated_glosses.rb            # every language
#   ruby tool/find_untranslated_glosses.rb kannada    # one language
#   ruby tool/find_untranslated_glosses.rb kannada -v # list every entry

require 'json'

def normalize(value)
  value.to_s.downcase.gsub(/\A[^a-z0-9]+/, '').gsub(/[^a-z0-9]+\z/, '')
end

# A gloss may qualify itself ("filter (coffee)") or offer choices
# ("tea/chai"). Each meaning is judged on its own.
def alternatives(gloss)
  gloss.gsub(/\([^)]*\)/, ' ')
       .split(%r{[,/;]})
       .map { |part| normalize(part) }
       .reject(&:empty?)
end

def teaches_nothing?(word, gloss)
  subject = normalize(word)
  return true if subject.empty?

  alternatives(gloss).include?(subject)
end

verbose = ARGV.delete('-v') || ARGV.delete('--verbose')
wanted = ARGV.first

paths = Dir.glob('assets/courses/*/dictionary.json').sort
paths.select! { |path| File.basename(File.dirname(path)) == wanted } if wanted
abort("No dictionary found for #{wanted.inspect}") if paths.empty?

total = 0
flagged_total = 0

paths.each do |path|
  language = File.basename(File.dirname(path))
  dictionary = JSON.parse(File.read(path))
  flagged = dictionary.select { |word, gloss| teaches_nothing?(word, gloss) }

  total += dictionary.size
  flagged_total += flagged.size
  share = dictionary.empty? ? 0 : (flagged.size * 100.0 / dictionary.size)

  puts format('%-12s %5d of %5d entries teach nothing (%.1f%%)',
              language, flagged.size, dictionary.size, share)
  next unless verbose

  flagged.sort.each { |word, gloss| puts "    #{word} -> #{gloss}" }
end

puts
puts format('Total: %d of %d entries (%.1f%%) are unusable as questions.',
            flagged_total, total, total.zero? ? 0 : flagged_total * 100.0 / total)
puts 'They stay in the dictionary for word hints; the app skips them when'
puts 'generating exercises.'
