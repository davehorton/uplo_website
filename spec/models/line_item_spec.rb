require 'spec_helper'

describe LineItem do
  it { should belong_to(:image) }
  it { should belong_to(:product) }
  it { should belong_to(:order) }

  it { should validate_numericality_of(:quantity) }


end

