require "crsfml"
require "./bindings"

#
module Input
  extend self

  # =======================================================================================
  # Class variables
  # =======================================================================================

  @@default_bindings = Bindings.new
  @@bindings = Bindings.new

  # =======================================================================================
  # Bindings functions
  # =======================================================================================

  # Sets up the default input bindings based on *yaml* data.
  def default_bindings=(yaml : YAML::Any)
    parse_yaml yaml, @@default_bindings
  end

  # Sets up the default input bindings based on a *yaml_string*.
  # This is a shortcut for `default_bindings = YAML.parse(yaml_string)`.
  def default_bindings=(yaml_string : String)
    self.default_bindings=(YAML.parse(yaml_string))
  end

  # Loads the default input bindings from a *file*.
  # This is a shortcut for `default_bindings = File.open(file) { |f| YAML.parse f }`.
  def load_default_bindings(file : Path | String)
    self.default_bindings=(File.open(file) { |f| YAML.parse f })
  end

  # Sets up the custom input bindings based on *yaml* data.
  def bindings=(yaml : YAML::Any)
    parse_yaml yaml, @@bindings
  end

  # Sets up the custom input bindings based on a *yaml_string*.
  # This is a shortcut for `bindings = YAML.parse(yaml_string)`.
  def bindings=(yaml_string : String)
    self.bindings=(YAML.parse(yaml_string))
  end

  # Loads custom input bindings from a *file*.
  # This is a shortcut for `bindings = File.open(file) { |f| YAML.parse f }`.
  def load_bindings(file : Path | String)
    self.bindings=(File.open(file) { |f| YAML.parse f })
  end

  # =======================================================================================
  # Event processing
  # =======================================================================================

  # Call this method in your CrSFML window's event loop to let CrSFML-Input handle the *sfml_event*.
  # The return value is either the name of the input event if a binding was found, or `nil` otherwise.
  def event?(sfml_event : SF::Event) : String?
    case sfml_event
    when SF::Event::KeyEvent
      modifiers = Bindings::Modifiers::None
      {% for which in [:L, :R] %} {% for key in [:Shift, :Control, :Alt, :System] %}
      modifiers |= Bindings::Modifiers:{{which}}{% if key == :Control %}Ctrl{% else %}{{key.id}}{% end %} if SF::Keyboard.key_pressed?(SF::Keyboard:{{which}}{{key.id}})
      {% end %} {% end %}
      key = sfml_event.code

      if event = @@bindings.key_pressed_bindings[{modifiers, key}]?
        event
      elsif default_event = @@default_bindings.key_pressed_bindings[{modifiers, key}]?
        if @@bindings.key_pressed_bindings.values.includes? default_event
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

  # Sets up the (default or customized) *bindings* based on the *customization* provided as a `YAML::Any`.
  private def parse_yaml(customization : YAML::Any, bindings : Bindings)
    events = customization["events"].as_h
    events.each do |event, binding_types|
      key_bindings = binding_types["key"]
      if array = key_bindings.as_a?
        array.each do |key_binding|
          bindings.add_key_pressed_binding event.as_s, key_binding.as_s
        end
      else
        bindings.add_key_pressed_binding event.as_s, key_bindings.as_s
      end
    end
  end

end
