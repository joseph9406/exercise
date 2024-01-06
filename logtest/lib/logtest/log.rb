
module Logtest
  module Log
    def logger        
      puts "**** 執行 logger 方法 ****"
      @@instance ||= Logtest::LoggerFactory.logger  # @@instance 是類變量,同一個類所產生的多個實例,只會共用同一個@@instance
    end
  end

  class LoggerFactory
    BASE_LOG_SIZE = 1024 * 1024 # 1MB

    SETTINGS = {
        # .expand_path,将相对路径转换为绝对路径。to_s,将绝对路径转换为字符串。
        #:settings_directory => Pathname.new(__dir__).join("..", "..", "..", "config", "settings.d").expand_path.to_s,
        :https_port => 8443,
        :log_file => "/var/log/logtest/logtest.log",
        :file_rolling_keep => 6,
        :file_rolling_size => 0,
        :file_rolling_age => 'weekly',
        :file_logging_pattern => '%d %c %.8X{request} [%.1l] %m',
        :system_logging_pattern => '%m',
        :log_level => "INFO",
        :daemon => false,
        :daemon_pid => "/var/run/foreman-proxy/foreman-proxy.pid",
        :forward_verify => true,
        :bind_host => ["*"],
        :log_buffer => 2000,
        :log_buffer_errors => 1000,
        :ssl_disabled_ciphers => [],
        :tls_disabled_versions => [],
        :dns_resolv_timeouts => [5, 8, 13], # Ruby default is [5, 20, 40] which is a bit too much for us
    }     
    
    begin
      require 'syslog/logger'
      @syslog_available = true
    rescue => LoadError
      @syslog_available = false
    end
   
    def self.logger      
      logger_name = 'Joseph-logger'   
      logger = Logging.logger.root
      layout        = Logging::Layouts.pattern(pattern: SETTINGS[:file_logging_pattern] + "\n")
      notime_layout = Logging::Layouts.pattern(pattern: SETTINGS[:system_logging_pattern] + "\n")
  
      if log_file.casecmp('STDOUT').zero?  # casecmp('STDOUT');不考慮字母大小,比較 log_file 和 "STDOUT" 是否相同, 若相同,則返回 0. 
        puts "**** (A) ****"
        if SETTINGS[:daemon]
          puts "若在守护进程模式下，表示应用程序在后台运行，通常不应将日志消息输出到标准输出,故在此情況下,输出一条错误消息并退出应用程序!"          
          puts "Settings log_file=STDOUT and daemon=true cannot be used together"
          exit(1)
        end          
        logger.add_appenders(Logging.appenders.stdout(logger_name, layout: layout))       
      elsif log_file.casecmp('SYSLOG').zero?
        puts "**** (B) ****"
        unless syslog_available?  # syslog_available? 是否支持系统日志功能。
          puts "Syslog is not supported on this platform, use STDOUT or a file"
          exit(1)
        end          
        logger.add_appenders(Logging.appenders.syslog(logger_name, layout: notime_layout, facility: ::Syslog::Constants::LOG_LOCAL5))    
      elsif log_file.casecmp('JOURNAL').zero? || log_file.casecmp('JOURNALD').zero?  # 是否要将日志输出到系统日志的 journal（日志系统）。
        begin
          puts "**** (C) ****"
          logger.add_appenders(Logging.appenders.journald(
            logger_name, layout: notime_layout, facility: ::Syslog::Constants::LOG_LOCAL5))
        rescue NoMethodError
          logger.add_appenders(Logging.appenders.stdout(logger_name, layout: layout))
          logger.warn "Journald is not available on this platform. Falling back to STDOUT."
        end
      else
        begin
          keep = SETTINGS[:file_rolling_keep]
          # 表示日志文件的大小阈值。这里使用了一个基础的日志文件大小 BASE_LOG_SIZE 乘以设置中的 file_rolling_size 参数来计算实际的大小阈值。
          size = BASE_LOG_SIZE * SETTINGS[:file_rolling_size]
          age = SETTINGS[:file_rolling_age]  # 获取日志文件滚动的参数 age，它表示日志文件的最大保存时间（按天计算）。
          if size > 0  # 如果 size 大于零，表示要启用日志文件滚动，以按大小滚动日志文件。 
            puts "**** (D) ****"           
            logger.add_appenders(Logging.appenders.rolling_file(logger_name, layout: layout, filename: log_file, keep: keep, size: size, age: age, roll_by: 'date'))
          else    
            puts "**** (E) ****"        
            # 表示不启用日志文件滚动，那么会使用 Logging.appenders.file 方法创建一个普通文件日志附加器,并将其添加到日志记录器中。
            # 这个附加器将把所有的日志消息追加到同一个文件中,不会按大小滚动。
            logger.add_appenders(Logging.appenders.file(logger_name, layout: layout, filename: log_file))
          end
        rescue ArgumentError => ae
          puts "**** (F) ****"
          logger.add_appenders(Logging.appenders.stdout(logger_name, layout: layout))
          logger.warn "Log file #{log_file} cannot be opened. Falling back to STDOUT: #{ae}"
        end
      end
      logger.level = ::Logging.level_num(SETTINGS[:log_level]) # ::Logging.level_num; 用于将日志级别名称（例如 "INFO"、"DEBUG"、"ERROR" 等）转换为对应的数字表示。
      logger
    end

    def self.log_file
      @log_file ||= SETTINGS[:log_file]
    end

  end
end


