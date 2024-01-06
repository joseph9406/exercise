require 'logtest/log'
require 'logtest/log1'

module Logtest
  class Launcher
    include ::Logtest::Log
    
    def initialize
      logger1= logger  
      logger1.info("******** (1)Joesph say: logger OK, #{logger1.object_id} ***********")      
    end

    def launch
      logger2 = logger       
      logger2.info("******** (2)授命于天,繼壽永昌: launch , #{logger2.object_id} ***********")    
      logger2.info("******** (3)我是龍王, #{logger2.object_id}  ***********")    
    end

    def myputs(settings)
      puts "***** 以下顯示 settings 的內容: *****"
      settings.each_pair do |key, value|
        puts "#{key}: #{value}"
      end
    end    

  end
end