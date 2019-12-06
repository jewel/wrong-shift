#!/usr/bin/env ruby

keycodes = {}
IO.popen( "xmodmap -pke" ) do |io|
  while line = io.gets
    next unless line =~ /^keycode\s+(\d+) = (\w+)/
    keycodes[$1] = $2
  end
end

left_side = %w{
  grave 1 2 3 4 5
  Tab q w e r t
  a s d f g
  z x c v b
}
right_side = %w{
  6 7 8 9 0 minus equal
  y u i o p bracketleft bracketright backslash
  h j k l semicolon apostrophe Return
  n m comma period slash
}

left_shift = false
right_shift = false

IO.popen( "xinput test-xi2 --root", 'r' ) do |io|
  loop do
    line = io.gets
    next unless line =~ /^EVENT type (2|3) \((\w+)\)/
    event = $2
    key_press = event == "KeyPress"
    key_release = event == "KeyRelease"
    detail = nil
    loop do
      line = io.gets
      break if line == "\n"
      next unless line =~ /^    (\w+): (.*)$/
      # double line break comes late, but "windows" is always the last
      # attribute according to the source code
      break if $1 == "windows"
      detail = $2 if $1 == "detail"
    end
    keycode = keycodes[detail]
    next unless keycode
    case keycode
    when "Shift_L"
      left_shift = key_press
    when "Shift_R"
      right_shift = key_press
    end
    next unless key_press
    if left_side.member?(keycode) && left_shift
      puts "\7bad Shift_L for #{keycode}"
    end
    if right_side.member?(keycode) && right_shift
      puts "\7bad Shift_R for #{keycode}"
    end
  end
end
