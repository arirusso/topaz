# Topaz

![pic](http://img526.imageshack.us/img526/5781/topazt.jpg)

MIDI syncable tempo in Ruby

## Installation

`gem install midi-topaz`

  or with Bundler, add this to your Gemfile

`gem "midi-topaz"`

## Usage

```ruby
require "topaz"
```

For demonstration purposes, here's a mock sequencer class and object

```ruby
class Sequencer

  def step
    @i ||= 0
    puts "step #{@i+=1}"
  end

end

sequencer = Sequencer.new
```

The Topaz clock can now be used to step that sequencer.  Timed by Topaz, the passed in block will be called repeatedly at 130 BPM

```ruby
@clock = Topaz::Clock.new(130) { sequencer.step }
```

A MIDI device can be used to time and control the tempo.  To accomplish this, pass a [unimidi](https://github.com/arirusso/unimidi) input to the Clock constructor

```ruby
@input = UniMIDI::Input.gets # select a midi input

@clock = Topaz::Clock.new(@input) { sequencer.step }
```

Topaz can also act as a MIDI master clock. If a MIDI output is passed to Topaz, MIDI clock messages will automatically be sent to that output at the appropriate time

```ruby
@output = UniMIDI::Output.gets # select a midi output

@clock = Topaz::Clock.new(120, :midi => @output) do
  sequencer.step
end
```

Input and multiple outputs can be used simultaneously, for MIDI thru

```ruby
@clock = Topaz::Clock.new(@input, :midi => [@output1, @output2]) do
  sequencer.step
end
```

Once the Clock object is initialized, start the clock

```ruby
@clock.start
```

Topaz will run in a background thread if the option `:background => true` is passed in.

```ruby
@clock.start(:background => true)
```

If you are syncing to an external MIDI source, this will start the listener waiting for MIDI clock messages.

You can view the current tempo:

```ruby
@clock.tempo
  => 132.422000
```

Pass in a block that will stop the clock when it evaluates to true

```ruby
@clock.trigger.stop { @i == 20 }
```

## Documentation

* [examples](http://github.com/arirusso/topaz/tree/master/examples)
* [rdoc](http://rdoc.info/gems/midi-topaz)

## Author

* [Ari Russo](http://github.com/arirusso) <ari.russo at gmail.com>

## License

Apache 2.0, See the file LICENSE

Copyright (c) 2011-2015 Ari Russo
