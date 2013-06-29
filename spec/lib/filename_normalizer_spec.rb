require "spec_helper"

describe FilenameNormalizer do
  it "returns normalized filename" do
    FilenameNormalizer.normalize("test%file 1.jpg").should eql("test-file-1.jpg")
  end

  context "with a capital extension" do
    it "preserves case" do
      FilenameNormalizer.normalize("test%file 1.JPG").should eql("test-file-1.JPG")
    end
  end

  context "without an extension" do
    it "returns normalized filename defaulting to .jpg" do
      FilenameNormalizer.normalize("test%file 1").should eql("test-file-1.jpg")
    end
  end
end