require 'spec_helper'

describe Cart do

  it { should belong_to(:user) }
  it { should belong_to(:order) }
  it { should have_many(:line_items).through(:order) }

  describe "#clear" do
    it "should destroy all associated line items" do
      pending "has many through association seems broken"
    end
  end

end
