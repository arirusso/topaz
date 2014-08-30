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

The simplest application of Topaz is to create a clock to step that sequencer at a given rate.  Using timing generated internally by your computer, the passed in block will be called repeatedly at 130 BPM

```ruby
@tempo = Topaz::Tempo.new(130) { sequencer.step }
```

You may also use another MIDI device to generate timing and control the tempo.  The unimidi input to which that device is connected can be passed to the Tempo constructor    

```ruby
@input = UniMIDI::Input.first.open # an midi input 
  
@tempo = Topaz::Tempo.new(@input) { sequencer.step }
```
        
Topaz can also act as a master clock. If a MIDI output is passed to Topaz, MIDI start, stop and clock signals will automatically be sent to that output at the appropriate time

```ruby
  @output = UniMIDI::Output.first.open # a midi output 
  
  @tempo = Topaz::Tempo.new(120, :midi => @output) { sequencer.step }
```

Input and multiple outputs can be used simultaneously

```ruby
@tempo = Topaz::Tempo.new(@input, :midi => [@output1, @output2]) { sequencer.step }
```

Once the Tempo object is initialized, start the clock

```ruby
  @tempo.start
```

If you are syncing to external clock, nothing will happen until a "start" or "clock" message is received
  
#### Other things to note

Whether or not you are using an internal or external clock source, the event block will be called at quarter note intervals by default.  If you wish to change this set the option :interval.  In this case, the event will be fired 4 times per beat (16th notes) at 138 BPM   

```ruby
@tempo = Topaz::Tempo.new(138, :interval => 16) do
  sequencer.step
end
```
  
View the current tempo, which is calculated by Topaz if you're using an external MIDI source.
(this feature is currently in-progress and may return some low values - 5/26/2011)

```ruby
@tempo.tempo
  => 132.422000
```

Run the generator in a background thread by passing :background => true to Tempo#start

```ruby
@tempo.start(:background => true)
```
  
Pass in a block that will stop the clock when it evaluates to true

```ruby
@tempo.stop_when { @i.eql?(20) }
```
    
## Documentation

* [examples](http://github.com/arirusso/topaz/tree/master/examples)
* [rdoc](http://rdoc.info/gems/midi-topaz)

## Author

* [Ari Russo](http://github.com/arirusso) <ari.russo at gmail.com>

## License

Apache 2.0, See the file LICENSE

Copyright (c) 2011-2014 Ari Russo
