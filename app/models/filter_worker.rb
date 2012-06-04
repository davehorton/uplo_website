# require 'iron_worker'

# class FilterWorker < IronWorker::Base
#   attr_accessor :rails_root #from iron_worker config
#   attr_accessor :aws_s3 #from iron_worker config
#   attr_accessor :image_url
#   attr_accessor :image_id
#   attr_accessor :effect

#   merge_gem "aws/s3"
#   merge "filter_effect.rb"

#   def run
#     tmp = image_url.split('?').first.split('/').last
#     file_path = "#{user_dir}#{image_id}"
#     filtered_path = FilterEffect::Effect.send(effect, image_url, file_path)

#     s3 = AWS::S3.new({
#       :access_key_id     => aws_s3["access_key_id"],
#       :secret_access_key => aws_s3["secret_access_key"]
#     })
#     bucket = s3.buckets[aws_s3["bucket"]]
#     obj = bucket.objects["image/#{image_id}/#{tmp}"]
#     obj.write({:file => filtered_path, :acl => :public_read_write})
#   end
# end