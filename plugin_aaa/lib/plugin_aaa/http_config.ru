require 'plugin_aaa/myapp1'
require 'plugin_aaa/myapp2'
require 'plugin_aaa/my_decorator'
# https://localhost:8443/hello/everyone # 測試範例

map '/hello' do
  use MyDecorator::Decorator1
  map '/user1' do
    run Plugin_aaa::MyApp1.new
  end

  map '/everyone' do
    use MyDecorator::Decorator2
    run Plugin_aaa::MyApp2.new
  end

  map '/' do
    run lambda {|env| 
      [ 200, 
        {"Content-type" => "text/html"}, 
        ["For SSL Test. Hi,this is Joseph. From hello catch all...<br/>", "SCRIPT_NAME=#{env["SCRIPT_NAME"]}<br/>", "PATH_INFO=#{env["PATH_INFO"]}<br/>"]
      ]
    }
  end 
end

map '/' do
  run lambda { |env| [200, {"Content-type" => "text/html"}, ["root\n"]]  }
end
