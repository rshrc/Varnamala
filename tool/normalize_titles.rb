#!/usr/bin/env ruby
# frozen_string_literal: true

# Put level titles into sentence case, leaving target-language ones alone.
#
# Decided per title, not per word. A title containing any romanized
# target-language word (in the language's dictionary, and not a word that is
# also ordinary English) is a target-language title and is left untouched — so
# "Ma, Deuta, Bhai, Bhoni" survives while "Asking The Shopkeeper" is fixed.
#
# Usage:
#   ruby tool/normalize_titles.rb            # dry run, shows what would change
#   ruby tool/normalize_titles.rb --apply

require_relative 'courses'

module NormalizeTitles
  # Words that appear in these dictionaries as romanized target-language words
  # but are also ordinary English, so they cannot signal "this is a target
  # title" on their own.
  ENGLISH = %w[
    a an the and or but if so of in on at to for with from by as about out up down
    is are am was were be been do does did have has had can will would you your my me
    i it its this that these those we our they them their he she his her who what when
    where how why which much many more less not no yes time day days week home work
    school food money good bad new old one two three ten hundred
  ].to_set.freeze

  module_function

  def sentence_case(title)
    title.split.each_with_index.map do |word, index|
      index.zero? || word == word.upcase ? word : word[0].downcase + word[1..]
    end.join(' ')
  end

  def main(argv)
    apply = argv.include?('--apply')
    changed = examined = skipped = 0
    samples = []

    Courses.languages.each do |language|
      dictionary_path = Courses::COURSES_DIR / language / 'dictionary.json'
      unless dictionary_path.exist?
        # Without a dictionary there is no way to tell a target-language title
        # from an English one; leave the language alone until it has one.
        puts "skipping #{language}: no dictionary yet"
        next
      end
      known = Courses.read_json(dictionary_path).keys.map { |w| Courses.normalize_word(w) }.to_set

      Courses.course_files(language).each do |path|
        data = Courses.read_json(path)
        dirty = false

        data['levels'].each do |level|
          title = level['title']
          examined += 1

          target_title = title.split.any? do |word|
            key = Courses.normalize_word(word)
            known.include?(key) && !ENGLISH.include?(key)
          end
          if target_title
            skipped += 1
            next
          end

          updated = sentence_case(title)
          next if updated == title

          changed += 1
          dirty = true
          samples << "  #{language}/#{path.basename('.json')} L#{level['level']}: #{title.inspect} -> #{updated.inspect}" if samples.size < 12
          level['title'] = updated
        end

        Courses.write_json(path, data) if dirty && apply
      end
    end

    puts samples
    puts "\n#{changed} English titles #{apply ? 'changed' : 'would change'}; " \
         "#{skipped} target-language titles left untouched; #{examined} examined"
    0
  end
end

exit NormalizeTitles.main(ARGV) if $PROGRAM_NAME == __FILE__
