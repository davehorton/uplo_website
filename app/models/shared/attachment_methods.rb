module Shared
  module AttachmentMethods
    def self.included(base)
      base.send :before_save, :normalize_filename
    end

    private

      def normalize_filename
        each_attachment do |name, attachment|
          file_name = attachment.instance_read(:file_name)
          attachment.instance_write(:file_name, FilenameNormalizer.normalize(file_name)) if file_name
        end
      end
  end
end