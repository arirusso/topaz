dir = File.dirname(File.expand_path(__FILE__))
$LOAD_PATH.unshift dir + "/../lib"

require "test/unit"
require "topaz"

module TestHelper 
end

require File.dirname(__FILE__) + "/config"
