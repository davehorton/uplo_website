require 'spec_helper'

describe CommentDecorator do
  stub_image_processing(Comment)

  let(:comment) { create(:comment) }
  let(:decorator) { klass.new(comment) }

  describe "#duration" do
    it "returns text" do
      decorator.duration.should be
    end
  end
end
