require 'spec_helper'

describe Authentication do
  it "should be valid" do
    Authentication.new.should be_valid
  end
end
