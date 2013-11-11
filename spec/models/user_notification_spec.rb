require 'spec_helper'

describe UserNotification do
  it { should respond_to(:push_comment) }
  it { should respond_to(:comment_email) }

  it { should belong_to(:user) }
  it { should validate_presence_of(:user_id) }

end
