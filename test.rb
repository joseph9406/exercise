
class Decorator1
  def initialize(app)
    @app = app
  end

  def call(env)
    status,headers,body = @app.call(env)
    new_body = "*****(1) Decorator 1 *****\n"
    body.each { |str| new_body << str }
    new_body << "\n********* end **********"
    headers["Context-Length"] = new_body.bytesize.to_s
    [status,headers,[new_body]]
  end
end

class Decorator2
  def initialize(app)
    @app = app
  end

  def call(env)
    status,headers,body = @app.call(env)
    new_body = "*****(2) Decorator 2 *****\n"
    body.each { |str| new_body << str }
    new_body << "\n********* end **********"
    headers["Context-Length"] = new_body.bytesize.to_s
    [status,headers,[new_body]]
  end
end

class Decorator3
  def initialize(app)
    @app = app
  end

  def call(env)
    status,headers,body = @app.call(env)
    new_body = "*****(3) Decorator 3 *****\n"
    body.each { |str| new_body << str }
    new_body << "\n********* end **********"
    headers["Context-Length"] = new_body.bytesize.to_s
    [status,headers,[new_body]]
  end
end

class Decorator4
  def initialize(app)
    @app = app
  end

  def call(env)
    status,headers,body = @app.call(env)
    new_body = "*****(4) Decorator 4 *****\n"
    body.each { |str| new_body << str }
    new_body << "\n********* end **********"
    headers["Context-Length"] = new_body.bytesize.to_s
    [status,headers,[new_body]]
  end
end

app1 = lambda {|env|
   [ 200,
     { "context-type" => "text/html" },
     [ "from user1\n", 
        "SCRIPT_NAME = #{env["SCRIPT_NAME"]}\n",
        "PATH_INFO=#{env["PATH_INFO"]}"]
   ]
 }

 app2 = lambda {|env|
   [ 200,
     { "context-type" => "text/html" },
     [ "from everyone\n", 
        "HTTP_USER_AGENT = #{env["HTTP_USER_AGENT"]}\n",
        "REQUEST_URI=#{env["REQUEST_URI"]}"]
   ]
  }
 

 app3 = lambda {|env|
   [200,
    { "context-type" => "text/html" },
    [ "from hello catch all\n", "This is app3\n",
      "HTTP_ACCEPT_LANGUAGE = #{env["HTTP_ACCEPT_LANGUAGE"]}\n",
      "REQUEST_URI = #{env["REQUEST_URI"]}"]
   ]
  }
 
  app2 = lambda {|env|
   [ 200,
    { "context-type" => "text/html" },
    [ "from everyone\n", 
      "HTTP_USER_AGENT = #{env["HTTP_USER_AGENT"]}\n",
      "REQUEST_URI=#{env["REQUEST_URI"]}"]
   ]
 }
