require "./spec_helper"

module CrInput
  extend self

  describe "CrInput" do
    describe ".def_map" do
      it "allows defining input events via YAML" do
        def_map <<-YAML_HEREDOC
        events:
          step:
            key: Up
          rush:
            key: Ctrl+Up
            # Shift, Alt, System, LCtrl, RShift etc. work just as well
          # Event names may contain spaces as well
          show help:
            key: [Alt+H, F1]
            # By using sequences, you can define multiple key bindings for the same event
        YAML_HEREDOC
        @@default_map.key_pressed_event.size.should be > 0
        event = SF::Event::KeyPressed.new
        event.code = SF::Keyboard::Key::Up
        lookup(event).should eq "step"
        event.code = SF::Keyboard::Key::F1
        lookup(event).should eq "show help"
      end
    end

    # ---------------------------------------------------------------------------------------

    describe ".load_map" do
      it "loads a mapping from a YAML file" do
        load_map "#{__DIR__}/../bindtest.yml"
        @@map.key_pressed_event.size.should be > 0
      end

      it "overwrites the default values without compromising them" do
        old_event = SF::Event::KeyPressed.new
        old_event.code = SF::Keyboard::Key::Up
        lookup(old_event).should be_nil
        new_event = SF::Event::KeyPressed.new
        new_event.code = SF::Keyboard::Key::Down
        lookup(new_event).should eq "step"
        still_same = SF::Event::KeyPressed.new
        still_same.code = SF::Keyboard::Key::F1
        lookup(still_same).should eq "show help"
      end
    end

    # ---------------------------------------------------------------------------------------

    describe ".lookup" do
      it "can be used in an CrSFML event loop to map SF::Events to input events" do
        fork do
          some_font_file = `fc-list : file | head -n 1`.chomp.gsub(/:.*/, "")
          font = SF::Font.from_file some_font_file
          text = SF::Text.new
          text.font = font

          start_time = Time.monotonic
          window = SF::RenderWindow.new(SF::VideoMode.new(600, 300), "Test")
          while window.open?
            while event = window.poll_event
              case event
              when SF::Event::Closed then window.close; break
              end
            end

            text.string =  "Please press the following key(s) within the next #{60 - (Time.monotonic - start_time).total_seconds.floor} seconds"

            window.draw text
            window.display
          end
        end
      end
    end
  end
end
