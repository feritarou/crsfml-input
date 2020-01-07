[![GitHub release](https://img.shields.io/github/release/mathalaxy/crinput.svg)](https://github.com/mathalaxy/crinput/releases)

[![Build Status](https://travis-ci.org/mathalaxy/crinput.svg?branch=master)](https://travis-ci.org/mathalaxy/crinput)

[![Docs](https://img.shields.io/badge/docs-available-brightgreen.svg)](https://mathalaxy.github.io/crinput/)

# CrInput
**Customizable input for CrSFML apps**

A library for customizable key/mouse/joystick bindings on top of [CrSFML](https://github.com/oprypin/crsfml#readme)'s event-driven and continuous input facilities. User input is organized around "input events" and "input queries". What CrSFML input is mapped to these entities then depends on a YAML file (or a part of it), which is easily customizable.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     crinput:
       github: mathalaxy/crinput
   ```

2. Run `shards install`

## Usage

### Preparations

Include CrInput by requiring it from your project:
```crystal
require "crinput"
# CrInput requires "crsfml" for you
```
### Defining input events

You need to define some (abstract) input events and default bindings (concrete keys). Choose descriptive names for them - something like `toggle pause` or `jump` - and build them into a YAML structure like this:
```crystal
yaml = <<-HEREDOC
events:
  step:
    key: Up
  rush:
    key: Ctrl+Shift+Up
    # Alt, System, LCtrl, RShift etc. work just as well
  show help:
    # multiple key bindings for the same event:
    key:
    - F1
    - Alt+H
HEREDOC
```
Finally, you must let CrInput know about your events with a call to `CrInput.def_map(yaml)`. There are overloads that take a `YAML::Any` or read YAML directly from a file, in case you dislike embedding your defaults within the code.

### Custom bindings

Once the *default* bindings are set up for all available events, you can now easily override them with (user) *customized* ones by replacing (parts of) your YAML with new data (possibly from another file):

```crystal
# Override just selected input effects; all other default bindings remain in effect
CrInput.load_map <<-NEW_YAML
events:
  show help:
    key: Ctrl+H
NEW_YAML

# Load customized mappings directly from a file
CrInput.load_map "bindtest.yml"

# Only use a subset of a bigger YAML file
cfg = YAMl.parse "config.yml"
if node = cfg.dig("custom", "input", "user-overrides")
  CrInput.load_map node
end
```

### Using input events
To use your abstract input events in a CrSFML app, simply place a call to `CrInput.lookup(event)` within your event loop and `case` its return value instead of the SFML event itself:

```crystal
# Create a CrSFML window
window = SF::Window.new(SF::VideoMode.new(400, 300), "Hi")

while window.open?
  while ev = window.poll_event
    # a nested case switch lets you
    # define the subset of CrSFML
    # events CrInput should handle
    case ev
    when SF::Event::Closed
      window.close; break
    when SF::Event::MouseButtonClicked
      # handle it
    else
      # Let lookup process the CrSFML event.
      # If a mapping is defined for ev,
      # it returns the respective input event.
      case CrInput.lookup(ev)
      when "step"
        # ...
      when "rush"
        # ...
      when "show help"
        # ...
      else
        # return value is nil if no mapping is found
      end
    end
  end

  window.clear
  window.display
end
```

## Development

Planned features list:

- Handle the following *input events*:
  - [x] keyboard events
  - [ ] joystick button events
  - [ ] mouse button events
  - [ ] mouse wheel events
- Handle the following *input queries*:
  - [ ] keyboard states
  - [ ] mouse button states
  - [ ] joystick button states
  - [ ] joystick axes states

## Contributing

1. Fork it (<https://github.com/mathalaxy/crinput/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [mathalaxy](https://github.com/mathalaxy) - creator and maintainer
