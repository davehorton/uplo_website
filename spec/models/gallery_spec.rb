require 'spec_helper'

describe Gallery do
  let(:gallery){ create(:gallery) }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:user) }

  it { should belong_to(:user) }
  it { should have_many(:images) }

#  it "validates uniqueness of name" do
 #   user = create(:user)
  #  gallery = create(:gallery, :name => "test", :user_id => user.id)
   # should validate_uniqueness_of(:name)
  #end

  describe "#cover_image" do

  end

end


