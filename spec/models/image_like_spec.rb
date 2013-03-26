require 'spec_helper'

describe ImageLike do
  it { should belong_to(:image) }
  it { should belong_to(:user) }
end
