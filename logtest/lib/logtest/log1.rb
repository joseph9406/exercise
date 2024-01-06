require 'logging'

module Logtest
  module Log1

    def logger 
        # 创建一个日志记录器
        logger = Logging.logger[self.class.name]
        
        # 创建一个输出到文件的 appender
        file_appender = Logging.appenders.file('my_log.log')
        file_appender.layout = Logging.layouts.pattern(
          pattern: '%d %c [%l] %m\n',
          date_pattern: '%Y-%m-%d %H:%M:%S'
        )
        logger.add_appenders(file_appender)
        
        # 创建一个输出到标准输出的 appender
        stdout_appender = Logging.appenders.stdout
        stdout_appender.layout = Logging.layouts.pattern(
          pattern: '%d %c [%l] %m\n',
          date_pattern: '%Y-%m-%d %H:%M:%S'
        )

        logger.add_appenders(stdout_appender)

        logger
    end

  end
end