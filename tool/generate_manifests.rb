#!/usr/bin/env ruby
# frozen_string_literal: true

# Write assets/courses/<language>/manifest.json for every supported language.
#
# The course set, icons, colours and tree layout are identical across languages —
# only the language's own name and romanization convention differ — so they are
# generated from one table rather than kept in sync by hand.

require_relative 'courses'

module GenerateManifests
  # Node colours are computed, not hand-picked, so the fifteen course circles
  # read as one family instead of a bag of stickers.
  #
  # Each course gets a hue; saturation is fixed, and lightness is solved per hue
  # so that every colour lands on the same *relative luminance*. That matters
  # twice over: perceptually the nodes carry equal visual weight (no circle
  # shouts louder than its neighbours the way a pure #FF0000 does next to a
  # grey), and the white glyph on top keeps an identical contrast ratio on all
  # fifteen.
  #
  # Hues are spaced so that consecutive courses — the ones you see together as
  # you scroll the path — are always far apart on the wheel, while semantics
  # still fit where they can: food is orange, health red, travel cyan, basics
  # the brand teal.
  TARGET_LUMINANCE = 0.25 # ~3.5:1 against white — clears WCAG 1.4.11 (3:1) for icon glyphs
  SATURATION = 0.68

  # id, title, icon (assets/images/<icon>.png), hue
  COURSES = [
    ['basics',        'Basics',          'egg',       174],
    ['greetings',     'Greetings',       'hand',       45],
    ['introductions', 'Introductions',   'pen',       285],
    ['family',        'Family',          'family',    335],
    ['food',          'Food & Drink',    'food',       25],
    ['numbers',       'Numbers',         'hammer',    215],
    ['colours',       'Colours',         'bucket',    310],
    ['travel',        'Travel',          'airplane',  195],
    ['time',          'Time & Days',     'calendar',  250],
    ['shopping',      'Shopping',        'chest',      80],
    ['health',        'Health',          'bandages',    5],
    ['home',          'At Home',         'book',      150],
    ['work',          'Work & School',   'student',   225],
    ['emotions',      'Feelings',        'emotion',   265],
    ['festivals',     'Festivals',       'celebrate', 350]
  ].freeze

  # Row sizes for the winding course map: singles, pairs and triples alternating.
  TREE_SHAPE = [1, 1, 2, 3, 1, 2, 3, 1, 1].freeze

  # language => [native name, romanization convention]
  LANGUAGES = {
    'tamil' => ['தமிழ்', 'Tanglish'],
    'kannada' => ['ಕನ್ನಡ', 'Kanglish'],
    'telugu' => ['తెలుగు', 'Tenglish'],
    'malayalam' => ['മലയാളം', 'Manglish'],
    'hindi' => ['हिन्दी', 'Hinglish'],
    'bengali' => ['বাংলা', 'Banglish'],
    'odia' => ['ଓଡ଼ିଆ', 'Romanized Odia'],
    'nepali' => ['नेपाली', 'Romanized Nepali'],
    'assamese' => ['অসমীয়া', 'Romanized Assamese'],
    'gujarati' => ['ગુજરાતી', 'Romanized Gujarati'],
    'marathi' => ['मराठी', 'Romanized Marathi'],
    'urdu' => ['اردو', 'Roman Urdu'],
    'sanskrit' => ['संस्कृतम्', 'Romanized spoken Sanskrit']
  }.freeze

  module_function

  # sRGB channel to linear light, per WCAG.
  def linear(channel)
    channel <= 0.03928 ? channel / 12.92 : (((channel + 0.055) / 1.055)**2.4)
  end

  def luminance(rgb)
    r, g, b = rgb.map { |channel| linear(channel) }
    (0.2126 * r) + (0.7152 * g) + (0.0722 * b)
  end

  def hue_to_channel(m1, m2, hue)
    hue %= 1.0
    return m1 + ((m2 - m1) * hue * 6.0) if hue < 1.0 / 6.0
    return m2 if hue < 0.5
    return m1 + ((m2 - m1) * ((2.0 / 3.0) - hue) * 6.0) if hue < 2.0 / 3.0

    m1
  end

  def hls_to_rgb(hue, lightness, saturation)
    return [lightness] * 3 if saturation.zero?

    m2 = lightness <= 0.5 ? lightness * (1.0 + saturation) : lightness + saturation - (lightness * saturation)
    m1 = (2.0 * lightness) - m2
    [hue_to_channel(m1, m2, hue + (1.0 / 3.0)),
     hue_to_channel(m1, m2, hue),
     hue_to_channel(m1, m2, hue - (1.0 / 3.0))]
  end

  # Hex for a hue at the shared target luminance.
  #
  # Yellow at 50% lightness is far brighter than blue at 50%; holding lightness
  # constant would make the yellow node glare and the blue node sink. So solve
  # for the lightness that puts every hue on the same luminance instead.
  def course_color(hue)
    low = 0.0
    high = 1.0
    40.times do # bisection; luminance rises monotonically with lightness
      mid = (low + high) / 2.0
      if luminance(hls_to_rgb(hue / 360.0, mid, SATURATION)) < TARGET_LUMINANCE
        low = mid
      else
        high = mid
      end
    end
    rgb = hls_to_rgb(hue / 360.0, (low + high) / 2.0, SATURATION)
    "0xff#{rgb.map { |channel| format('%02X', (channel * 255).round) }.join}"
  end

  def tree
    ids = COURSES.map(&:first)
    raise 'tree shape must cover every course' unless TREE_SHAPE.sum == ids.size

    offset = 0
    TREE_SHAPE.map do |size|
      row = ids[offset, size]
      offset += size
      row
    end
  end

  def main
    LANGUAGES.each do |language, (native, romanization)|
      directory = Courses::COURSES_DIR / language
      directory.mkpath
      manifest = {
        'language' => language,
        'nativeName' => native,
        'romanization' => romanization,
        'tree' => tree,
        'courses' => COURSES.map do |id, title, icon, hue|
          { 'id' => id, 'title' => title, 'icon' => icon, 'color' => course_color(hue) }
        end
      }
      path = directory / 'manifest.json'
      Courses.write_json(path, manifest)
      puts "wrote #{path.relative_path_from(Courses::ROOT)}"
    end
    0
  end
end

exit GenerateManifests.main if $PROGRAM_NAME == __FILE__
