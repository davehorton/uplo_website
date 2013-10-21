require 'spec_helper'

describe ApplicationHelper do
  let(:image) { create(:image, image_file_name: 'long_image_name_for_test.jpg')}

  describe "#formatted_image_name" do

    context "with truncation" do
      it "should truncate and return image name" do
        helper.formatted_image_name(image, 20).should == 'long_image_name_for_test'.humanize.titleize.truncate(20)
      end
    end

    context "without truncation" do
      it "should return entire image name titleized" do
        helper.formatted_image_name(image).should == 'long_image_name_for_test'.humanize.titleize
      end
    end

  end
end
