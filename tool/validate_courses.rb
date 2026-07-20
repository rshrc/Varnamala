#!/usr/bin/env ruby
# frozen_string_literal: true

# Validate every language's course JSON under assets/courses/.
#
# Checks the manifest wiring, per-course structure, question schema, and
# dictionary coverage of every romanized word a learner can tap. Exits non-zero
# if anything fails, so it can gate a commit.
#
# Usage:
#   ruby tool/validate_courses.rb                    # all languages
#   ruby tool/validate_courses.rb tamil              # one language
#   ruby tool/validate_courses.rb path/to/course.json  # one file, while authoring

require_relative 'courses'

module ValidateCourses
  include Courses

  LEVELS = (5..6).freeze
  QUESTIONS = (8..10).freeze
  OPTION_COUNT = 3
  NAME_TOKEN = '{name}'
  NAME_ALLOWED_IN = %w[basics introductions].freeze

  MC_PROMPT = 'Choose an appropriate response'
  TRANSLATE_PROMPT = 'Translate the sentence'

  MC_KEYS = %w[type prompt sentence sentenceIsTargetLanguage
               options correctAnswer translatedSentence].freeze
  TRANSLATE_KEYS = (MC_KEYS - ['translatedSentence']).freeze

  module_function

  def check_question(question, where, report, course_id, vocabulary)
    kind = question['type']
    unless %w[multiple_choice translate].include?(kind)
      report.error(where, "unknown type #{kind.inspect}")
      return
    end

    expected_keys = kind == 'multiple_choice' ? MC_KEYS : TRANSLATE_KEYS
    missing = expected_keys - question.keys
    extra = question.keys - expected_keys
    report.error(where, "missing keys #{missing.sort}") unless missing.empty?
    report.error(where, "unexpected keys #{extra.sort}") unless extra.empty?
    return unless missing.empty?

    expected_prompt = kind == 'multiple_choice' ? MC_PROMPT : TRANSLATE_PROMPT
    if question['prompt'] != expected_prompt
      report.error(where, "prompt should be #{expected_prompt.inspect}, got #{question['prompt'].inspect}")
    end

    options = question['options']
    unless options.is_a?(Array) && options.size == OPTION_COUNT
      report.error(where, "expected #{OPTION_COUNT} options, got #{options.is_a?(Array) ? options.size : 0}")
      return
    end
    report.error(where, 'options contain a duplicate') if options.uniq.size != options.size
    unless options.include?(question['correctAnswer'])
      report.error(where, "correctAnswer #{question['correctAnswer'].inspect} is not one of the options")
    end

    report.error(where, 'sentenceIsTargetLanguage must be true') unless question['sentenceIsTargetLanguage'] == true

    sentence = question['sentence']
    report.error(where, 'empty sentence') if sentence.strip.empty?
    report.warn(where, "single-word sentence #{sentence.inspect}") if sentence.split.size < 2

    # The tappable dictionary only covers the target-language strings: the
    # prompt sentence always, plus the options when they are the reply.
    vocabulary.merge(Courses.words_in(sentence))
    if kind == 'multiple_choice'
      options.each { |option| vocabulary.merge(Courses.words_in(option)) }
      report.error(where, 'empty translatedSentence') if question['translatedSentence'].strip.empty?
      if question['correctAnswer'].split.size < 2
        report.warn(where, 'single-word correctAnswer reads like a flashcard')
      end
    elsif options.any? { |option| !option.strip.end_with?('?', '.', '!') }
      # translate options are English meanings.
      report.warn(where, 'an English option is missing end punctuation')
    end

    question.each do |field, value|
      text = value.is_a?(String) ? value : ''
      if text.include?(NAME_TOKEN) && !NAME_ALLOWED_IN.include?(course_id)
        report.error(where, "#{NAME_TOKEN} used outside #{NAME_ALLOWED_IN}")
      end
      report.error(where, "stray '$' in #{field}") if text.include?('$')
    end
  end

  def check_course(path, course_id, report, vocabulary)
    data = Courses.read_json(path)
    where = "#{path.parent.basename}/#{path.basename}"

    if data['course'] != course_id
      report.error(where, "course field is #{data['course'].inspect}, expected #{course_id.inspect}")
    end
    report.error(where, 'missing description') if data['description'].to_s.strip.empty?

    levels = data['levels'] || []
    report.error(where, "#{levels.size} levels, expected #{LEVELS.min}-#{LEVELS.max}") unless LEVELS.cover?(levels.size)

    sentences = Hash.new(0)
    levels.each_with_index do |level, index|
      level_where = "#{where} L#{level['level'] || '?'}"
      if level['level'] != index + 1
        report.error(level_where, "levels must be numbered 1..n, found #{level['level'].inspect} at position #{index + 1}")
      end
      report.error(level_where, 'missing title') if level['title'].to_s.strip.empty?

      questions = level['questions'] || []
      unless QUESTIONS.cover?(questions.size)
        report.error(level_where, "#{questions.size} questions, expected #{QUESTIONS.min}-#{QUESTIONS.max}")
      end

      kinds = questions.group_by { |q| q['type'] }.transform_values(&:size)
      if !questions.empty? && (kinds['multiple_choice'].nil? || kinds['translate'].nil?)
        report.warn(level_where, "level uses only one question type (#{kinds})")
      end

      questions.each_with_index do |question, position|
        check_question(question, "#{level_where} Q#{position + 1}", report, course_id, vocabulary)
        sentences[question['sentence'].to_s] += 1
      end
    end

    sentences.each do |sentence, count|
      report.error(where, "sentence repeated #{count}x: #{sentence.inspect}") if count > 1
    end

    [levels.size, levels.sum { |level| (level['questions'] || []).size }]
  end

  def check_non_ascii(path, report, where = nil)
    path.read.each_line.with_index(1) do |line, line_no|
      report.error("#{where || path.basename}:#{line_no}", 'non-ASCII character') unless line.ascii_only?
    end
  end

  def check_language(language, report)
    directory = Courses::COURSES_DIR / language
    manifest_path = directory / 'manifest.json'
    unless manifest_path.exist?
      report.error(language, 'manifest.json is missing')
      return nil
    end

    manifest = Courses.read_json(manifest_path)
    listed = manifest['courses'].map { |course| course['id'] }
    in_tree = manifest['tree'].flatten

    (in_tree - listed).uniq.each do |cid|
      report.error("#{language}/manifest.json", "tree references unknown course #{cid.inspect}")
    end
    (listed - in_tree).uniq.each do |cid|
      report.error("#{language}/manifest.json", "course #{cid.inspect} never appears in the tree")
    end
    manifest['tree'].each do |row|
      unless (1..3).cover?(row.size)
        report.error("#{language}/manifest.json", "tree row of #{row.size} renders nothing (allowed: 1-3)")
      end
    end

    manifest['courses'].each do |course|
      icon = Courses::IMAGES_DIR / "#{course['icon']}.png"
      report.error("#{language}/manifest.json", "icon #{icon.basename} does not exist") unless icon.exist?
      unless course['color'].match?(/\A0x\h{8}\z/)
        report.error("#{language}/manifest.json", "bad colour #{course['color'].inspect}")
      end
    end

    vocabulary = Set.new
    levels = 0
    questions = 0
    listed.each do |cid|
      path = directory / "#{cid}.json"
      unless path.exist?
        report.error(language, "#{cid}.json is missing")
        next
      end
      course_levels, course_questions = check_course(path, cid, report, vocabulary)
      levels += course_levels
      questions += course_questions
    end

    # Non-ASCII would break the romanized-only rule; the manifest is exempt
    # because it carries each language's own name.
    exempt = Courses::NON_COURSE_FILES - ['dictionary.json']
    directory.glob('*.json').sort.each do |path|
      next if exempt.include?(path.basename.to_s)

      check_non_ascii(path, report, "#{language}/#{path.basename}")
    end

    dictionary_path = directory / 'dictionary.json'
    covered = 0
    if dictionary_path.exist?
      entries = Courses.read_json(dictionary_path)
      known = entries.keys.map { |word| Courses.normalize_word(word) }.to_set
      entries.each do |word, gloss|
        report.error("#{language}/dictionary.json", "empty gloss for #{word.inspect}") if gloss.strip.empty?
      end
      vocabulary.delete(Courses.normalize_word(NAME_TOKEN))
      missing = (vocabulary - known).sort
      covered = vocabulary.size - missing.size
      unless missing.empty?
        preview = missing.first(12).join(', ')
        report.error("#{language}/dictionary.json",
                     "#{missing.size} of #{vocabulary.size} words have no gloss: #{preview}" \
                     "#{missing.size > 12 ? ' ...' : ''}")
      end
    else
      report.error(language, 'dictionary.json is missing')
    end

    { language:, courses: listed.size, levels:, questions:,
      vocabulary: vocabulary.size, covered: }
  end

  # Validate one course file on its own — used while authoring, before the rest
  # of a language exists.
  def check_single_file(path, report)
    path = Pathname.new(path)
    unless path.exist?
      report.error(path.to_s, 'file does not exist')
      return
    end
    return if Courses::NON_COURSE_FILES.include?(path.basename.to_s)

    vocabulary = Set.new
    levels, questions = check_course(path, path.basename('.json').to_s, report, vocabulary)
    check_non_ascii(path, report)
    puts "#{path}: #{levels} levels, #{questions} questions, #{vocabulary.size} distinct words"
  end

  def main(argv)
    report = Courses::Report.new

    if argv.first&.end_with?('.json')
      argv.each { |arg| check_single_file(arg, report) }
      report.print_all
      puts report.ok? ? 'OK' : 'FAILED'
      return report.ok? ? 0 : 1
    end

    rows = Courses.languages(argv).filter_map { |language| check_language(language, report) }

    width = rows.map { |row| row[:language].size }.max || 8
    puts format("%-#{width}s  courses  levels  questions  vocabulary", 'language')
    rows.each do |row|
      puts format("%-#{width}s  %7d  %6d  %9d  %5d/%d",
                  row[:language], row[:courses], row[:levels],
                  row[:questions], row[:covered], row[:vocabulary])
    end
    puts "\n#{rows.sum { |row| row[:questions] }} questions across #{rows.size} languages"

    report.print_all
    if report.ok?
      puts "\nall checks passed (#{report.warnings.size} warning(s))"
      0
    else
      puts "\n#{report.errors.size} error(s), #{report.warnings.size} warning(s)"
      1
    end
  end
end

exit ValidateCourses.main(ARGV) if $PROGRAM_NAME == __FILE__
