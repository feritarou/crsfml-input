require "yaml"
require "bit_array"

module CrInput

  class Mapping

    # =======================================================================================
    # Enums
    # =======================================================================================

    @[Flags]
    enum Modifier
      LShift; RShift
      LCtrl; RCtrl
      LAlt; RAlt
      LSystem; RSystem
    end

    # =======================================================================================
    # Instance properties
    # =======================================================================================

    getter key_pressed_event = {} of {Modifier, SF::Keyboard::Key} => String

    # =======================================================================================
    # Map creation functions
    # =======================================================================================

    def add_key_pressed_event(name : String, binding : String)
      tuples = parse_key_binding(binding)
      tuples.each do |t|
      	@key_pressed_event[t] = name
      end
    end

    # =======================================================================================
    # Helper functions
    # =======================================================================================

    private def parse_key_binding(string)
      key_name = string.match(/[^+]*$/).not_nil![0]
      code = SF::Keyboard::Key.parse key_name

      mod_sets = [Modifier::None]

      while matched = string.match(/^[LR]?(Ctrl|Shift|Alt|System)\+/)
        word = matched[0]
        s1 = word.rchop.downcase
        Modifier.each do |mod|
          s2 = mod.to_s.downcase
          if s1 == s2
            mod_sets.map! { |ms| ms | mod }
            break
          elsif s1 == s2.lchop
            one, the_other, both = mod_sets.clone, mod_sets.clone, mod_sets.clone
            other = Modifier.parse("#{s2[0] == 'l' ? 'R' : 'L'}#{mod.to_s.lchop}")
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
  end
end
