module Plugin_aaa
  class MyApp1
    def call(env)
      [ 200, {}, ["For SSL Test, this is MyApp1\n", "Hello,nice to meet you!\n", "What a wonderful day!\n"] ] 
    end
  end
end
  