module Aliases
  def self.included(base)
    base.extend(ClassMethods)
  end

  def klass
    described_class
  end

  module ClassMethods
    # keeps tests faster by stubbing out file system operations
    def stub_image_processing(model)
      before do
        model.any_instance.stub(:save_attached_files).and_return(true)
        model.any_instance.stub(:delete_attached_files).and_return(true)
        Paperclip::Attachment.any_instance.stub(:post_process).and_return(true)

        # stub image methods that communicate with Paperclip
        Image.any_instance.stub(:init_image_info)
        Image.any_instance.stub(:validate_quality => true)
        Image.any_instance.stub(:width => 100)
        Image.any_instance.stub(:height => 100)
      end
    end
  end
end