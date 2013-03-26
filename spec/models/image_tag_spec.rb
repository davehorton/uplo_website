require 'spec_helper'

describe ImageTag do
  it { should belong_to(:image) }
  it { should belong_to(:tag) }
end
