require "./crsfml-input"

default_bindings = <<-YAML_HEREDOC
events:
  step:
    key: Up
  rush:
    key: Ctrl+Up
    # Shift, Alt, System, LCtrl, RShift etc. work just as well
  # Event names may contain spaces as well
  show help:
    key: [F1, Alt+H]
    # By using sequences, you can define multiple key bindings for the same event
YAML_HEREDOC

Input.default_bindings = default_bindings

loaded_bindings = File.read "bindtest.yml"
Input.load_bindings "bindtest.yml"

events = ["step", "rush", "show help"]
cursor = 0
mastered = false

some_font_file = `fc-list :lang=en : file | head -n 1`.chomp.gsub(/:.*/, "")
font = SF::Font.from_file some_font_file
text = SF::Text.new
text.fill_color = SF::Color::Black
text.font = font
text.character_size = 15

start_time = Time.monotonic
TIMEOUT = 20

vm = SF::VideoMode.new(600, 300)
window = SF::RenderWindow.new(vm, "Test")

while window.open?
  while event = window.poll_event
    case event
    when SF::Event::Closed then window.close; break
    when SF::Event::Resized
      visible_area = SF.float_rect(0, 0, event.width, event.height)
      window.view = SF::View.new(visible_area)
    else
      unless mastered
        if input_event = Input.event?(event)
          cursor += 1 if events[cursor] == input_event
        end
      end
    end
  end

  elapsed = (Time.monotonic - start_time).total_seconds.floor

  if cursor < events.size
    if elapsed >= TIMEOUT
      window.close
      break
    end
    event = events[cursor]
    text.string =  "You got #{TIMEOUT - elapsed} seconds to cause the following input events:\n                      #{event}\n\nDefault bindings:\n#{default_bindings}\n\nLoaded bindings:\n#{loaded_bindings}"
  elsif mastered
    if elapsed > 3
      window.close
      break
    end
  else
    text.string = "Whoohoo! You made it!"
    mastered = true
    start_time = Time.monotonic
  end

  window.clear SF.color(220, 220, 220)
  window.draw text
  window.display

  sleep 50.milliseconds
end

exit mastered ? 0 : 1
