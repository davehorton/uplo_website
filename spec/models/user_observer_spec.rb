require 'spec_helper'

describe UserObserver do
  around(:each) do |example|
    User.observers.enable  :user_observer
    example.run
    User.observers.disable :user_observer
  end
end
