{% if system("cd #{__DIR__}/.. && find . -path ./lib/crsfml").empty? %}
# If CrSFML is unavailable, emulate its structure with dummies so crystal docs does not fail
module SF::Keyboard
  enum Key
    Dummy
  end
end
{% else %}
require "crsfml"
{% end %}

require "./bindings"
require "./static_functions"

{% if flag?(:libtest) %}
require "../test"
{% end %}
