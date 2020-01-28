require "yaml"

module Input

  class Bindings

    # =======================================================================================
    # Enums
    # =======================================================================================

    @[Flags]
    enum Modifiers
      LShift; RShift
      LCtrl; RCtrl
      LAlt; RAlt
      LSystem; RSystem
    end

    # =======================================================================================
    # Type aliases
    # =======================================================================================

    # One particular key, or key/modifiers combination, that can be bound to an input event/input query.
    alias KeyBinding = {Modifiers, SF::Keyboard::Key}

    # One particular button of one particular joystick that can be bound to an input event/input query.
    record JoystickButtonBinding, joystick_id : Int32, button : Int32

    # One particular axis of one particular joystick that can be bound to an input position query.
    record JoystickAxisBinding, joystick_id : Int32, axis : SF::Joystick::Axis

    alias AnyBinding = KeyBinding | JoystickButtonBinding | JoystickAxisBinding

    # =======================================================================================
    # Instance properties
    # =======================================================================================

    # Returns all registered key bindings for input events.
    getter key_pressed_bindings = {} of KeyBinding => String

    # Returns all registered joystick button bindings for input events.
    getter joystick_button_pressed_bindings = {} of JoystickButtonBinding => String

    # Returns all registered bindings for input queries.
    getter query_bindings = {} of String => Set(AnyBinding)

    # =======================================================================================
    # Binding creation functions
    # =======================================================================================

    def add_key_pressed_binding(name : String, binding : String)
      tuples = parse_key_binding(binding)
      tuples.each do |t|
      	@key_pressed_bindings[t] = name
      end
    end

    def add_key_query_binding(name : String, binding : String)
      tuples_array = parse_key_binding(binding)
      if @query_bindings.has_key? name
        @query_bindings[name].concat tuples_array
      else
        @query_bindings[name] = Set(AnyBinding).new tuples_array
      end
    end

    def add_joystick_button_pressed_binding(name : String, binding : String)
      tuples = parse_joystick_button_binding(binding)
      tuples.each do |t|
      	@joystick_button_pressed_bindings[t] = name
      end
    end

    def add_joystick_axis_query_binding(name : String, joystick_id : Int32, binding : String)
      axis = parse_joystick_axis_binding(binding)
      jab = JoystickAxisBinding.new(joystick_id, axis)
      if @query_bindings.has_key? name
        @query_bindings[name] << jab
      else
        @query_bindings[name] = Set(AnyBinding){jab}
      end
    end

    # =======================================================================================
    # Helper functions
    # =======================================================================================

    # Parses a *string* representation of a particular key/key combination into a `KeyBinding`.
    private def parse_key_binding(string)
      key_name = string.match(/[^+]*$/).not_nil![0]
      code = SF::Keyboard::Key.parse key_name

      mod_sets = [Modifiers::None]

      while matched = string.match(/^[LR]?(Ctrl|Shift|Alt|System)\+/)
        word = matched[0]
        s1 = word.rchop.downcase
        Modifiers.each do |mod|
          s2 = mod.to_s.downcase
          if s1 == s2
            mod_sets.map! { |ms| ms | mod }
            break
          elsif s1 == s2.lchop
            one, the_other, both = mod_sets.clone, mod_sets.clone, mod_sets.clone
            other = Modifiers.parse("#{s2[0] == 'l' ? 'R' : 'L'}#{mod.to_s.lchop}")
            one.map! { |ms| ms | mod }
            the_other.map! { |ms| ms | other }
            both.map! { |ms| ms | mod | other }
            mod_sets = one + the_other + both
            break
          end
        end
        string = string.lchop(word)
      end

      mod_sets.map { |mods| {mods, code} }
    end

    private def parse_joystick_button_binding(string)
      # This is a stub!
      [ JoystickButtonBinding.new(0, 0)]
      #TODO: Implement joystick button bindings as named backreferences
      # to a definition of the particular button within the same YAML data
    end

    private def parse_joystick_axis_binding(string)
      SF::Joystick::Axis.parse string
    end
  end
end
