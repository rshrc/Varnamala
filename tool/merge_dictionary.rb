#!/usr/bin/env ruby
# frozen_string_literal: true

# Merge glossed word chunks into a language's dictionary.json.
#
# Chunks are authored separately (one agent per few hundred words), so this
# folds them into the single sorted file the app ships. Existing glosses win — a
# hand correction is never overwritten by a regenerated chunk.
#
# Usage:
#   ruby tool/merge_dictionary.rb tamil /tmp/varnamala-dict/tamil.part*.json

require_relative 'courses'

module MergeDictionary
  module_function

  def main(argv)
    language, *parts = argv
    abort 'usage: ruby tool/merge_dictionary.rb <language> <part.json>...' if parts.empty?

    target = Courses::COURSES_DIR / language / 'dictionary.json'
    merged = target.exist? ? Courses.read_json(target) : {}
    before = merged.size
    skipped = 0

    parts.each do |part|
      Courses.read_json(part).each do |word, gloss|
        key = Courses.normalize_word(word)
        if key.empty? || gloss.to_s.strip.empty?
          skipped += 1
          next
        end
        merged[key] ||= gloss.to_s.strip
      end
    end

    Courses.write_json(target, merged.sort.to_h)
    puts "#{language}: #{before} -> #{merged.size} entries (#{parts.size} parts, #{skipped} unusable)"
    0
  end
end

exit MergeDictionary.main(ARGV) if $PROGRAM_NAME == __FILE__
