module Plugin_aaa
  class MyApp2        
    def call(env)
      [ 200, {}, [ "This is MyApp2\n", "SSl SSL SSL SSL", "AAAAA AAAAA\n", "BBB BBBB BBBBB\n" ] ]  
    end
  end
end
  