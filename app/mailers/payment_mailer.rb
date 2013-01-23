class PaymentMailer < ApplicationMailer
  def transaction_finish(order)
    @order = order
    @user = order.user

    in_tmpdir do |tmpdir, path|
      @order.images.each do |image|
        io = open(URI.parse(image.data.url(:original)))
        def io.original_filename; base_uri.path.split('/').last; end
        io.original_filename.blank? ? nil : io
        attachments.inline["#{image.id}.jpg"] = File.read(io.path)
      end
      subject = I18n.t("order.email.transaction_finish_subject")
      mail_params = {
        :to => @user.friendly_email,
        :subject => subject
      }
      
      mail(mail_params)
    end
  end

  def inform_new_order(order)
    subject = I18n.t("order.email.inform_new_order")
    @user = order.user
    @order = order
    mail_params = {
      :to => ["quynh.kim@techpropulsionlabs.com", "uplo@digital2media.com"],
      :subject => subject
    }
    
    mail(mail_params)
  end

  protected
    def in_tmpdir
      path = File.expand_path "#{Rails.root.join('tmp')}/#{Time.now.to_i}#{rand(1000)}/"
      FileUtils.mkdir_p( path )

      begin 
        # Create temp file to export
        yield(path) # Pass temp folder and the path of temp file
       
      ensure
      end

    ensure
      FileUtils.rm_rf( path ) if File.exists?( path ) # Remove temp folder whatever happening
    end

end
