class PaymentMailer < ApplicationMailer
  def transaction_finish(order_id)
    @order = Order.unscoped.find(order_id)
    @user = order.user

    in_tmpdir do |tmpdir, path|
      @order.images.each do |image|
        io = open(URI.parse(image.url(:original)))
        def io.original_filename; base_uri.path.split('/').last; end
        io.original_filename.blank? ? nil : io
        attachments.inline["#{image.id}.jpg"] = File.read(io.path)
      end

      mail(
        to: @user.friendly_email,
        subject: I18n.t("order.email.transaction_finish_subject")
      )
    end
  end

  def inform_new_order(order_id)
    @order = Order.unscoped.find(order_id)
    @user = order.user

    mail(
      to: ["patrick@uplo.com", "uplo@digital2media.com"],
      subject: I18n.t("order.email.inform_new_order")
    )
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
