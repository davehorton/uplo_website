require 'spec_helper'
require 'sidekiq/testing/inline'

describe LineItem do
  let(:line_item) { create(:line_item, image: create(:real_image))}

  it { should belong_to(:image) }
  it { should belong_to(:product) }
  it { should belong_to(:order) }

  it { should validate_numericality_of(:quantity) }


  describe "#set_crop_dimension" do
    it "should set crop dimension field from a hash" do
      options = {crop_x: "1445", crop_y: "312", crop_w: "888", crop_h: "888"}
      line_item.set_crop_dimension(options)
      line_item.crop_dimension.should == "888x888+1445+312"
    end
  end

  describe "#cropped_dimensions" do
    it "should return an empty array" do
      line_item.cropped_dimensions.should == []
    end

    it "should not return an empty array" do
      options = {crop_x: "1445", crop_y: "312", crop_w: "888", crop_h: "888"}
      line_item.set_crop_dimension(options)
      line_item.cropped_dimensions.should == [888, 888, 1445, 312]
    end
  end

  describe "#copy_image" do
    it "should copy image, crop and save it" do
      line_item.update_attribute(:crop_dimension, "888x888+1445+312")
      line_item.copy_image
      line_item.url.should_not be_blank
      file_path = Rails.root.to_s + "/public" + line_item.url.split('?').first
      Paperclip::Geometry.from_file(file_path).to_s.should == "888x888"
    end
  end

end

