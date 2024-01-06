
#require 'rack'
#require 'webrick'
require 'bundler'
Bundler.require   # 加载 Gemfile 裏:default group 和當前環境對應的group

class MyApp1
  def call(env)
    [ 200, {"Content-type" => "text/html"}, ["This is SSL Test !<br/>", "SSL SSL SSL<br/>", "BBB BBB BBBB<br/>", "CC CCCCCC CCC<br/>"] ]
  end
end

#my_app = MyApp1.new  # 要一個實例
#Rack::Handler::WEBrick.run my_app, :Port => 3000
#==============================================

class MyApp2  
  def call(env)
    body = get_env(env)  # body是一個字符串
    [ 200, {"Content-type" => "text/html"}, body ]
  end

  def get_env(env)    
    env.map{|k,v| "#{k} => #{v}<br/>"}.sort
  end
end

#my_app = MyApp2.new
#Rack::Handler::WEBrick.run my_app, :Port => 3000
#================================================

class MyDecorator1
  def initialize(app)
    @app = app
  end
 
  def call(env)
    status, header, body = @app.call(env)        
    new_body = ["***** (1) SSL MyDecorator1 Start !! *****<br/>"]
    body.each {|str| new_body << str}
    new_body << "***** (1) SSL MyDecorator1  End !! *****<br/>"   
    [ status, header, new_body ]
  end
end

class MyDecorator2
  def initialize(app)
    @app = app
  end
 
  def call(env)
    status, header, body = @app.call(env)    
    puts "***(2) body is #{body.class} ***" 
    new_body = [ "@@@@@ (2) MyDecorator2 Test !! @@@@@<br/>" ]
    body.each {|str| new_body << str}
    new_body << "@@@@@ MyDecorator2 Test End !! @@@@@<br/>"   
    [ status, header, new_body ]
  end
end

class MyDecorator3
  def initialize(app)
    @app = app
  end
 
  def call(env)
    status, header, body = @app.call(env)   
    puts "***(3) body is #{body.class} ***"  
    new_body = [ "====== (3) MyDecorator3 Test !! ======<br/>" ]
    body.each {|str| new_body << str}
    new_body << "====== MyDecorator3 Test End !! ======<br/>"   
    [ status, header, new_body ]
  end
end

#my_app = MyApp1.new  # 要一個實例

#my_app = Rack::Builder.new { 
#  use MyDecorator1
#  run my_app
#}.to_app

#Rack::Handler::WEBrick.run my_app, :Port => 3000
#=====================================================

app = Rack::Builder.new { 
  use MyDecorator1
  map '/hello' do
    use MyDecorator2
    map '/user1' do
      run lambda {|env| 
        [200, {"Content-type" => "text/html"}, ["from user1<br/>", "SCRIPT_NAME=#{env["SCRIPT_NAME"]}<br/>", "PATH_INFO=#{env["PATH_INFO"]}<br/>"]]
      }
    end

    map '/everyone' do
      use MyDecorator3
      run lambda {|env| [200,
                         {"Content-type" => "text/html"},
                         ["from everyone<br/>", "SCRIPT_NAME=#{env["SCRIPT_NAME"]}<br/>", "PATH_INFO=#{env["PATH_INFO"]}<br/>"]]
      }
    end

    map '/' do
      run MyApp1.new
    end 
  end

  map '/' do
    run MyApp2.new
  end
}.to_app

#Rack::Handler::WEBrick.run app, :Port => 3000
#========================================================

mylaunch = Proxy::Launcher.new
settings = mylaunch.settings

#CIPHERS = ['ECDHE-RSA-AES128-GCM-SHA256', 'ECDHE-RSA-AES256-GCM-SHA384',
#           'AES128-GCM-SHA256', 'AES256-GCM-SHA384', 'AES128-SHA256',
#           'AES256-SHA256', 'AES128-SHA', 'AES256-SHA'].freeze

# 通过禁用这些不安全的协议版本和弱密码套件，可以提高 SSL/TLS 的整体安全性，确保系统使用更现代、更安全的加密标准。这对于防范针对协议漏洞和密码学弱点的攻击非常重要。
ssl_options = OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:options]  # 首先，将 ssl_options 初始化为 OpenSSL::SSL::SSLContext::DEFAULT_PARAMS 中的默认选项。
# 如果定义了 OpenSSL::SSL::OP_CIPHER_SERVER_PREFERENCE，则将其添加到 ssl_options 中。这个选项表示在使用服务器密码时,优先选择服"务器密码套件"而不是"客户端密码套件"。
ssl_options |= OpenSSL::SSL::OP_CIPHER_SERVER_PREFERENCE if defined?(OpenSSL::SSL::OP_CIPHER_SERVER_PREFERENCE)
# This is required to disable SSLv3 on Ruby 1.8.7
ssl_options |= OpenSSL::SSL::OP_NO_SSLv2 if defined?(OpenSSL::SSL::OP_NO_SSLv2) # OpenSSL::SSL::OP_NO_SSLv2,禁用 SSLv2 协议
ssl_options |= OpenSSL::SSL::OP_NO_SSLv3 if defined?(OpenSSL::SSL::OP_NO_SSLv3) # SLv3 也存在一些安全漏洞，包括 POODLE 攻击。禁用 SSLv3 可以防止使用这个存在漏洞的协议版本。
ssl_options |= OpenSSL::SSL::OP_NO_TLSv1 if defined?(OpenSSL::SSL::OP_NO_TLSv1) #  TLSv1.0 是一个较早的 TLS 版本，也存在一些安全问题。禁用 TLSv1 可以防止使用这个较旧的 TLS 协议版本。
ssl_options |= OpenSSL::SSL::OP_NO_TLSv1_1 if defined?(OpenSSL::SSL::OP_NO_TLSv1_1)  # TLSv1.1 是 TLS 的一个较早版本，为提高安全性，禁用 TLSv1.1 可以防止使用这个相对较旧的版本。

# Proxy::SETTINGS.tls_disabled_versions：这是一个数组，其中包含要禁用的 TLS 版本。通过循环迭代数组，将 OpenSSL 中相应的常量添加到 ssl_options 中。
Proxy::SETTINGS.tls_disabled_versions&.each do |version|  
  constant = OpenSSL::SSL.const_get("OP_NO_TLSv#{version.to_s.tr('.', '_')}") rescue nil

  if constant
    logger.info "TLSv#{version} will be disabled."
    ssl_options |= constant
  else
    logger.warn "TLSv#{version} was not found."
  end

end

=begin
def load_ssl_private_key(path)
  # 使用 File.read(path) 从指定路径读取私钥文件的内容，
  # 并使用 OpenSSL::PKey::RSA.new 方法创建一个 OpenSSL::PKey::RSA 实例，表示一个 RSA 密钥对。
  OpenSSL::PKey::RSA.new(File.read(path))
rescue Exception => e
  puts "Unable to load private SSL key. Are the values correct in settings.yml and do permissions allow reading?"
  raise e
end

def load_ssl_certificate(path)
  # 通过读取指定路径的证书文件,来创建一个 X.509 证书对象
  OpenSSL::X509::Certificate.new(File.read(path))
rescue Exception => e
  puts "Unable to load SSL certificate. Are the values correct in settings.yml and do permissions allow reading?"
  raise e
end
=end

https_app = {
  :app => app,
  :server => :webrick,
  :DoNotListen => true,   # 不会尝试监听任何地址或端口。这可以防止不必要的网络监听，特别是在一些特定用例中，服务器只需要处理内部请求或通过其他方式与外部通信。
  :Port => settings.https_port, # only being used to correctly log https port being used
  #:Logger => ::Proxy::LogBuffer::Decorator.instance,
  #:ServerSoftware => "foreman-proxy/#{Proxy::VERSION}",
  :SSLEnable => true,
  #:SSLVerifyClient => OpenSSL::SSL::VERIFY_PEER,  #  表示要验证客户端的证书。如果客户端未提供有效的证书，连接将被拒绝。
  :SSLPrivateKey => mylaunch.load_ssl_private_key(settings.ssl_private_key),   # 服務器私钥是与服务器证书配对的(證書裏有服務器公鈅)，用于建立安全连接。
  :SSLCertificate => mylaunch.load_ssl_certificate(settings.ssl_certificate),  # 服务器证书
  :SSLCACertificateFile => settings.ssl_ca_file,  # 服务器可以要求客户端提供证书。使用服务器上的CA证书来验证客户端提供的证书,以确保双向验证。
  :SSLOptions => ssl_options,
  :SSLCiphers => CIPHERS - Proxy::SETTINGS.ssl_disabled_ciphers,
  :daemonize => false,
}

addresses = ["*"]
port = settings.https_port

server = ::WEBrick::HTTPServer.new(https_app) 
addresses.each { |address| server.listen(address, port) }  # address,用于指定服务器监听地址的参数
# 若應用程序被掛載在 '/test'下,則只有以/test 为前缀的请求路径才会被匹配和传递给该应用程序处理。
server.mount "/", Rack::Handler::WEBrick, https_app[:app]  # 将应用程序 app[:app] 挂载到 WEBrick 服务器的根路径（"/"）上。
server.start