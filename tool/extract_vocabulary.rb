#!/usr/bin/env ruby
# frozen_string_literal: true

# List the romanized words a language's lessons use but its dictionary lacks.
#
# Every target-language word a learner can tap needs a gloss, so coverage is
# derived from the lessons rather than maintained by hand.
#
# Usage:
#   ruby tool/extract_vocabulary.rb tamil                 # missing words, one per line
#   ruby tool/extract_vocabulary.rb tamil --all           # every word used
#   ruby tool/extract_vocabulary.rb tamil --json out.json

require_relative 'courses'

module ExtractVocabulary
  module_function

  # Word => number of times it appears, across every lesson of a language.
  def vocabulary(language)
    counts = Hash.new(0)
    Courses.course_files(language).each do |path|
      Courses.read_json(path).fetch('levels', []).each do |level|
        level.fetch('questions', []).each do |question|
          Courses.words_in(question['sentence'].to_s).each { |word| counts[word] += 1 }
          next unless question['type'] == 'multiple_choice'

          question.fetch('options', []).each do |option|
            Courses.words_in(option).each { |word| counts[word] += 1 }
          end
        end
      end
    end
    counts.delete('name') # the {name} placeholder
    counts
  end

  def main(argv)
    language = argv.find { |arg| !arg.start_with?('--') }
    abort 'usage: ruby tool/extract_vocabulary.rb <language> [--all] [--json PATH]' unless language

    counts = vocabulary(language)
    unless argv.include?('--all')
      dictionary_path = Courses::COURSES_DIR / language / 'dictionary.json'
      known = if dictionary_path.exist?
                Courses.read_json(dictionary_path).keys.map { |w| Courses.normalize_word(w) }.to_set
              else
                Set.new
              end
      counts = counts.reject { |word, _| known.include?(word) }
    end

    # Most frequent first: the words worth getting right.
    ordered = counts.sort_by { |word, count| [-count, word] }.to_h

    json_index = argv.index('--json')
    if json_index
      out = argv[json_index + 1]
      Courses.write_json(out, ordered)
      puts "#{ordered.size} words -> #{out}"
    else
      ordered.each_key { |word| puts word }
    end
    0
  end
end

exit ExtractVocabulary.main(ARGV) if $PROGRAM_NAME == __FILE__
