# frozen_string_literal: true

require_relative "logtest/version"
require 'launcher'

module Logtest
  class Error < StandardError; end
  # Your code goes here...

  Logtest::Launcher.new.launch
  #Launcher.new.launch

end
