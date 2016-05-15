module Factory
  Dir[File.join('.', 'app', 'factories', '*.rb')].each { |rb| require rb }
end
