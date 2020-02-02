{% if system("cd #{__DIR__}/.. && find . -path ./lib/crsfml").empty? %}
# Workaround for Travis: If CrSFML is unavailable, emulate just enough of its structure with dummies to prevent crystal docs from failing
module SF::Keyboard
  enum Key; Dummy; end
end
module SF::Joystick
  enum Axis; Dummy; end
end
{% else %}
require "crsfml"
{% end %}

require "./bindings"
require "./static_functions"

{% if flag? :"libtest-crsfml-input" %}
require "../test"
{% end %}
