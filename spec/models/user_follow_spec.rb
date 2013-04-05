require 'spec_helper'

describe UserFollow do
  it { should belong_to(:followed_user) }
  it { should belong_to(:follower) }
end
