# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'spork', :rspec_env => { 'RAILS_ENV' => 'test' } do
  watch(%r{^app/controllers/.+\.rb$})
  watch(%r{^app/decorators/.+\.rb$})
  watch(%r{^app/helpers/.+\.rb$})
  watch(%r{^app/mailers/.+\.rb$})
  watch(%r{^app/models/.+\.rb$})
  watch(%r{^app/views/.+\.rb$})

  watch('config/application.rb')
  watch(%r{^config/environments/.+\.rb$})
  watch(%r{^config/initializers/.+\.rb$})

  watch(%r{^lib/(.+)\.rb})

  watch('Gemfile')
  watch('Gemfile.lock')

  watch('spec/spec_helper.rb')
  watch('spec/factories/')
  watch(%r{^spec/factories/.*\.rb$})
  watch('spec/support/')
  watch(%r{^spec/support/.*\.rb$})
end

guard 'coffeescript', :input => 'app/assets/javascripts', :noop => true
guard 'sass',         :input => 'app/assets/stylesheets', :noop => true
