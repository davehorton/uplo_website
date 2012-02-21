namespace :image do
  desc 'Update images demension info to DB'
  task :refresh_metadata => :environment do
    Image.all.each do |img|
      begin
        img.send(:save_image_dimensions)
        if img.changed?
          img.save(:validate => false)
        end
      rescue Exception => exc
        puts "Error"
        puts exc
        puts exc.backtrace.join("\n")
      end
    end
  end
end
