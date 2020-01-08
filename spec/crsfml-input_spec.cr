require "./spec_helper"

module Input
  describe "Input" do
    describe ".default_bindings=" do
      it "allows defining input events via YAML or String" do
        Input.default_bindings = <<-YAML_HEREDOC
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
        @@default_bindings.key_pressed_bindings.size.should be > 0
        ev = SF::Event::KeyPressed.new
        ev.code = SF::Keyboard::Key::Up
        Input.event?(ev).should eq "step"
        ev.code = SF::Keyboard::Key::F1
        Input.event?(ev).should eq "show help"
      end
    end

    # ---------------------------------------------------------------------------------------

    describe ".load_binding" do
      it "loads bindings from a YAML file" do
        Input.load_bindings "#{__DIR__}/../bindtest.yml"
        @@bindings.key_pressed_bindings.size.should be > 0
      end

      it "overwrites the default values without compromising them" do
        old_event = SF::Event::KeyPressed.new
        old_event.code = SF::Keyboard::Key::Up
        Input.event?(old_event).should be_nil
        new_event = SF::Event::KeyPressed.new
        new_event.code = SF::Keyboard::Key::Down
        Input.event?(new_event).should eq "step"
        still_same = SF::Event::KeyPressed.new
        still_same.code = SF::Keyboard::Key::F2
        Input.event?(still_same).should eq "show help"
      end
    end

    # ---------------------------------------------------------------------------------------

    # describe ".event?" do
    #   it "can be used in an CrSFML event loop to map SF::Events to input events" do
    #     # Must be tested in a separate process
    #     exit_status = Process.run("#{__DIR__}/../bin/test", shell: true)
    #     exit_status.success?.should be_true
    #   end
    # end
  end
end
