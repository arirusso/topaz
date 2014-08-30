module TestHelper::Config

  include UniMIDI

  # Adjust these constants to suit your hardware configuration
  # before running tests

  TestInput = Input.gets # this is the device you wish to use to test input
  TestOutput = Output.gets # likewise for output

end
