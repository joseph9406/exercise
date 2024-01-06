
map '/hello' do
  use Decorator1
  map '/user1' do
    run app1
  end

  map '/everyone' do
    use Decorator2
    run app2
  end

  map '/' do
    run app3
  end 
end

map '/' do
  run app4
end
