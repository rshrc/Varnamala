# frozen_string_literal: true

# Shared vocabulary for the course-content tools in this directory.
#
# Lesson content lives as JSON under assets/courses/<language>/ — see
# docs/course-authoring.md. These helpers are what every tool needs in common:
# where the content is, which files are courses, and how a word in a sentence is
# reduced to a dictionary key.

require 'json'
require 'pathname'
require 'set'

module Courses
  ROOT = Pathname.new(__dir__).parent
  COURSES_DIR = ROOT / 'assets' / 'courses'
  IMAGES_DIR = ROOT / 'assets' / 'images'

  # Files in a language directory that are not courses.
  NON_COURSE_FILES = ['manifest.json', 'dictionary.json', 'notes.json'].freeze

  module_function

  # Mirror of normalizeWord() in lib/courses/course_repository.dart: strips the
  # punctuation a word carries inside a sentence ("enna?" -> "enna") and
  # lowercases it, so a lookup matches however the word was written.
  def normalize_word(word)
    word.downcase.sub(/\A[^a-z0-9]+/, '').sub(/[^a-z0-9]+\z/, '')
  end

  def words_in(sentence)
    sentence.split.map { |part| normalize_word(part) }.reject(&:empty?)
  end

  # Every language directory, or just the ones named.
  def languages(only = [])
    return only unless only.empty?

    COURSES_DIR.children.select(&:directory?).map { |dir| dir.basename.to_s }.sort
  end

  def course_files(language)
    (COURSES_DIR / language).glob('*.json')
                            .reject { |path| NON_COURSE_FILES.include?(path.basename.to_s) }
                            .sort
  end

  def read_json(path)
    JSON.parse(Pathname.new(path).read)
  end

  def write_json(path, data)
    Pathname.new(path).write("#{JSON.pretty_generate(data)}\n")
  end

  # Collects problems so a tool can report everything it found in one pass
  # rather than dying on the first one.
  class Report
    attr_reader :errors, :warnings

    def initialize
      @errors = []
      @warnings = []
    end

    def error(where, message) = @errors << "#{where}: #{message}"
    def warn(where, message) = @warnings << "#{where}: #{message}"
    def ok? = @errors.empty?

    def print_all
      @warnings.each { |warning| puts "warning  #{warning}" }
      @errors.each { |error| puts "ERROR    #{error}" }
    end
  end
end
