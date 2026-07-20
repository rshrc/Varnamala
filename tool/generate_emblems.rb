#!/usr/bin/env ruby
# frozen_string_literal: true

# Write assets/emblems/<language>.svg — the card art for the language picker.
#
# One visual system: every emblem is a 64x64 rounded square with a two-stop
# gradient and a single white motif, so thirteen very different cultures still
# read as one set. Motifs represent the language's living culture rather than
# any religion or state — a Konark wheel for Odia, a kite for Gujarati, a reed
# pen for Urdu, a palm-leaf manuscript for Sanskrit.
#
# Regenerate with: ruby tool/generate_emblems.rb

require_relative 'courses'

module GenerateEmblems
  OUT = Courses::ROOT / 'assets' / 'emblems'

  FRAME = <<~SVG
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" width="64" height="64" role="img" aria-label="%<label>s">
      <defs>
        <linearGradient id="bg" x1="0" y1="0" x2="0.35" y2="1">
          <stop offset="0" stop-color="%<c1>s"/>
          <stop offset="1" stop-color="%<c2>s"/>
        </linearGradient>
      </defs>
      <rect width="64" height="64" rx="15" fill="url(#bg)"/>
      <g fill="none" stroke="#fff" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round">
    %<motif>s
      </g>
    </svg>
  SVG

  # language => [accessible label, colour 1, colour 2, motif paths]
  EMBLEMS = {
    # Mysuru palace domes.
    'kannada' => ['Kannada', '#FFB703', '#F97316', <<~PATHS.chomp],
        <path d="M18 44h28"/>
        <path d="M22 44V32a10 10 0 0 1 20 0v12"/>
        <path d="M32 22v-5"/>
        <path d="M14 44v-7a5 5 0 0 1 10 0"/>
        <path d="M50 44v-7a5 5 0 0 0-10 0"/>
    PATHS

    # Gopuram: a stepped temple tower.
    'tamil' => ['Tamil', '#EF233C', '#9D0208', <<~PATHS.chomp],
        <path d="M16 46h32"/>
        <path d="M20 46V36h24v10"/>
        <path d="M23 36V28h18v8"/>
        <path d="M26 28v-6h12v6"/>
        <path d="M32 22v-5"/>
        <path d="M28 46v-7h8v7"/>
    PATHS

    # Charminar: a four-minaret gateway.
    'telugu' => ['Telugu', '#9D4EDD', '#5A189A', <<~PATHS.chomp],
        <path d="M16 47h32"/>
        <path d="M21 47V27h22v20"/>
        <path d="M27 47v-9a5 5 0 0 1 10 0v9"/>
        <path d="M21 27h22"/>
        <path d="M19 27V19M45 27v-8"/>
        <path d="M17 19h4M43 19h4"/>
    PATHS

    # A chundan vallam snake boat on the backwaters.
    'malayalam' => ['Malayalam', '#40916C', '#1B5E3F', <<~PATHS.chomp],
        <path d="M12 36c6 8 34 8 40 0"/>
        <path d="M52 36c0-6-3-10-8-12"/>
        <path d="M44 24c3-1 5 0 6 2"/>
        <path d="M22 36v-6M30 36v-6M38 36v-6"/>
        <path d="M14 46c5-3 9-3 14 0s9 3 14 0"/>
    PATHS

    # A city gateway arch.
    'hindi' => ['Hindi', '#457B9D', '#1D3557', <<~PATHS.chomp],
        <path d="M15 47h34"/>
        <path d="M19 47V24h26v23"/>
        <path d="M26 47V35a6 6 0 0 1 12 0v12"/>
        <path d="M17 24h30"/>
        <path d="M32 24v-6"/>
    PATHS

    # Howrah bridge.
    'bengali' => ['Bengali', '#17A2B8', '#0B6E75', <<~PATHS.chomp],
        <path d="M10 42h44"/>
        <path d="M20 42V20M44 42V20"/>
        <path d="M17 20h6M41 20h6"/>
        <path d="M20 24l24 14M44 24L20 38"/>
        <path d="M10 42v5M54 42v5"/>
    PATHS

    # The Konark sun-temple wheel.
    'odia' => ['Odia', '#B5838D', '#6D6875', <<~PATHS.chomp],
        <circle cx="32" cy="32" r="18"/>
        <circle cx="32" cy="32" r="6"/>
        <path d="M32 14v6M32 44v6M14 32h6M44 32h6"/>
        <path d="M19.3 19.3l4.3 4.3M40.4 40.4l4.3 4.3M44.7 19.3l-4.3 4.3M23.6 40.4l-4.3 4.3"/>
    PATHS

    # Himalayan peaks under the sun.
    'nepali' => ['Nepali', '#E63946', '#1D3F8C', <<~PATHS.chomp],
        <path d="M10 46h44"/>
        <path d="M12 46l14-22 8 12 5-7 13 17"/>
        <path d="M22 32l4 3 4-3"/>
        <circle cx="44" cy="18" r="5"/>
    PATHS

    # A sprig of tea.
    'assamese' => ['Assamese', '#A7C957', '#4F772D', <<~PATHS.chomp],
        <path d="M32 50V22"/>
        <path d="M32 32c-8 0-12-4-12-10 6 0 12 3 12 10z"/>
        <path d="M32 32c8 0 12-4 12-10-6 0-12 3-12 10z"/>
        <path d="M32 42c-7 0-10-3-10-8 5 0 10 3 10 8z"/>
    PATHS

    # A Warli dancer — Maharashtra's folk art, painted white on mud walls.
    'marathi' => ['Marathi', '#C1440E', '#7C2D12', <<~PATHS.chomp],
        <circle cx="32" cy="17" r="4.5"/>
        <path d="M32 22l-7 10h14z"/>
        <path d="M32 32l-7 10h14z"/>
        <path d="M25 32l-9-5M39 32l9-5"/>
        <path d="M25 42l-5 8M39 42l5 8"/>
        <path d="M12 54c6-4 14-4 20 0s14 4 20 0" stroke-width="2"/>
    PATHS

    # An Uttarayan kite.
    'gujarati' => ['Gujarati', '#48CAE4', '#0077B6', <<~PATHS.chomp],
        <path d="M32 12l16 16-16 16-16-16z"/>
        <path d="M32 12v32M16 28h32"/>
        <path d="M32 44l-4 10"/>
        <path d="M28 48l4 2M26 52l4 2"/>
    PATHS

    # A qalam reed pen with its ink.
    'urdu' => ['Urdu', '#4B5563', '#111827', <<~PATHS.chomp],
        <path d="M46 14L22 38"/>
        <path d="M22 38l-5 12 12-5"/>
        <path d="M46 14l4 4-4 4-4-4z"/>
        <path d="M14 54c6-4 12-4 18 0s12 4 18 0" stroke-width="2"/>
    PATHS

    # A palm-leaf manuscript, bound through the middle.
    'sanskrit' => ['Sanskrit', '#D9A21B', '#A16207', <<~PATHS.chomp]
        <rect x="10" y="20" width="44" height="8" rx="4"/>
        <rect x="10" y="32" width="44" height="8" rx="4"/>
        <rect x="10" y="44" width="44" height="8" rx="4"/>
        <path d="M32 20v32" stroke-width="2"/>
        <path d="M32 14v6"/>
    PATHS
  }.freeze

  module_function

  def main
    OUT.mkpath
    EMBLEMS.each do |language, (label, c1, c2, motif)|
      path = OUT / "#{language}.svg"
      # The heredocs above are dedented for readability; put the indent back so
      # the emitted SVG nests under its <g>.
      indented = motif.lines.map { |line| "    #{line}" }.join
      path.write(format(FRAME, label:, c1:, c2:, motif: indented))
      puts "wrote #{path.relative_path_from(Courses::ROOT)}"
    end
    0
  end
end

exit GenerateEmblems.main if $PROGRAM_NAME == __FILE__
