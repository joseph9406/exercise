module MyDecorator
  class Decorator1
    def initialize(app)
        @app = app
    end
    
    def call(env)
        status, headers, body = @app.call(env)
        new_body = "=== Decorator1 Start ===\n"
        body.each { |str| new_body << "#{str}\n" }
        new_body << "=== Decorator1 End ==="
        headers["Content-Length"] = new_body.bytesize.to_s
        [status, headers, [new_body]]
    end
  end
    
  class Decorator2
    def initialize(app)
        @app = app
    end
    
    def call(env)
        status, headers, body = @app.call(env)
        new_body = "***** Decorator2 Start *****<br/>"
        body.each { |str| new_body << "#{str}\n" }
        new_body << "***** Decorator1 End *****"
        headers["Content-Length"] = new_body.bytesize.to_s
        [status, headers, [new_body]]
    end
  end
      
end