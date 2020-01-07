require "crsfml"
require "./mapping"

# A library for customizable bindings on top of [CrSFML](https://github.com/oprypin/crsfml#readme)'s event-driven and continuous input facilities. User input is organized around "input events" and "input queries". What CrSFML input is mapped to these entities then depends on a YAML file (or a part of it), which is easily customizable.
module CrInput
  extend self

  # =======================================================================================
  # Class variables
  # =======================================================================================

  @@default_map = Mapping.new
  @@map = Mapping.new

  # =======================================================================================
  # Mapping functions
  # =======================================================================================

  def def_map(yaml_string : String)
    def_map YAML.parse(yaml_string)
  end

  def def_map(yaml : YAML::Any)
    parse_yaml yaml, @@default_map
  end

  def map(yaml : YAML::Any)
    parse_yaml yaml, @@map
  end

  # Loads the input mapping from a *file*.
  # This is a shortcut for `CrInput.map File.open(file) { |f| YAML.parse f }`.
  def load_map(file : Path | String)
    CrInput.map File.open(file) { |f| YAML.parse f }
  end

  # =======================================================================================
  # Event processing
  # =======================================================================================

  # Call this function in your CrSFML window's event loop to let CrInput handle the *event*.
  # The return value is either the name of the input event if a mapping was found for the *event*, or `nil` otherwise.
  def lookup(event : SF::Event) : String?
    case event
    when SF::Event::KeyEvent
      modifiers = Mapping::Modifier::None
      {% for which in [:L, :R] %} {% for key in [:Shift, :Control, :Alt, :System] %}
      modifiers |= Mapping::Modifier:{{which}}{% if key == :Control %}Ctrl{% else %}{{key.id}}{% end %} if SF::Keyboard.key_pressed?(SF::Keyboard:{{which}}{{key.id}})
      {% end %} {% end %}
      key = event.code

      if input_event = @@map.key_pressed_event[{modifiers, key}]?
        input_event
      elsif default_event = @@default_map.key_pressed_event[{modifiers, key}]?
        if @@map.key_pressed_event.values.includes? default_event
          nil
        else
          default_event
        end
      end
    end
  end

  # =======================================================================================
  # Helper functions
  # =======================================================================================

  private def parse_yaml(yaml, mapping)
    events = yaml["events"].as_h
    events.each do |event, bindings|
      key_bindings = bindings["key"]
      if array = key_bindings.as_a?
        array.each do |key_binding|
          mapping.add_key_pressed_event event.as_s, key_binding.as_s
        end
      else
        mapping.add_key_pressed_event event.as_s, key_bindings.as_s
      end
    end
  end

end
