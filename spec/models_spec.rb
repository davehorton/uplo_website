# Run all Mixpanel unit test!
Dir[File.dirname(__FILE__) + '/models/*_spec.rb'].each do |file| 
  require file
end
