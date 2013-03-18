require 'spec_helper'

describe Comment do
  stub_image_processing(Comment)

  let(:comment) { create(:comment) }

  it { should belong_to(:image) }
  it { should belong_to(:user) }
  it { should belong_to(:active_user) }

  it { should validate_presence_of(:image) }
  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:description) }

  it "has a default sort of created_at desc" do
    a = create(:comment)
    b = create(:comment)
    klass.all.should == [b, a]
  end

  describe ".available" do
    it "finds comments linked to active users" do
      banned_user = create(:user, banned: true)
      create(:comment, user: banned_user)

      removed_user = create(:user, removed: true)
      create(:comment, user: removed_user)

      active_comment = create(:comment)
      klass.available.should == [active_comment]
    end
  end

  it "aliases commenter_id to user_id" do
    comment.commenter_id.should == comment.user_id
  end

  describe "#commenter" do
    it "delegates to user's username" do
      comment.commenter.should == comment.user.username
    end
  end

  describe "#commenter_avatar" do
    it "delegates to user's avatar url" do
      comment.commenter_avatar.should == comment.user.avatar_url('large')
    end
  end
end
