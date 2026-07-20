#!/usr/bin/env ruby
# frozen_string_literal: true

# Print the "<language>/<course>" jobs that still need authoring.
#
# A course counts as done only if its file exists and passes validation, so an
# interrupted generation run can be resumed without redoing good work.
#
# Usage:
#   ruby tool/remaining_courses.rb                  # every language
#   ruby tool/remaining_courses.rb tamil kannada    # only these
#   ruby tool/remaining_courses.rb --json           # as a JSON array

require 'stringio'

require_relative 'courses'
require_relative 'validate_courses'

module RemainingCourses
  module_function

  def main(argv)
    as_json = argv.include?('--json')
    named = argv.reject { |arg| arg.start_with?('--') }

    remaining = Courses.languages(named).flat_map do |language|
      manifest = Courses.read_json(Courses::COURSES_DIR / language / 'manifest.json')
      manifest['courses'].filter_map do |course|
        path = Courses::COURSES_DIR / language / "#{course['id']}.json"
        next "#{language}/#{course['id']}" unless path.exist?

        report = Courses::Report.new
        # check_single_file prints a summary line; swallow it here.
        original = $stdout
        $stdout = StringIO.new
        begin
          ValidateCourses.check_single_file(path, report)
        ensure
          $stdout = original
        end
        report.ok? ? nil : "#{language}/#{course['id']}"
      end
    end

    if as_json
      puts JSON.generate(remaining)
    else
      remaining.each { |job| puts job }
      warn "\n#{remaining.size} course files remaining"
    end
    0
  end
end

exit RemainingCourses.main(ARGV) if $PROGRAM_NAME == __FILE__
