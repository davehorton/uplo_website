module ImagesHelper
  # Generate Pinterest share link.
  # This link can be also used for 'Pin it' button.
  def image_pinterest_share_url(image, image_public_url = nil)
    image_public_url ||= url_for(
      :controller => 'images',
      :action => 'public',
      :id => image.id,
      :only_path => false
    )
    "http://pinterest.com/pin/create/button/?url=#{CGI.escape(image_public_url)}&description=#{"Share from UPLO: " + image.name}&media=#{CGI.escape(image.url(:spotlight_thumb))}"
  end

  def can_promote_image?(image, user = nil)
    user ||= current_user
    (current_user.is_admin? && !image.is_promoted? && !image.is_removed? && !image.is_flagged?)
  end

  # This is a helper to use with the JAIL (jQuery Asynchronous Image Loader plugin)
  def async_image_tag(source, options = {})
    options ||= {}
    image_html = ""
    if @no_async_image_tag
      image_html = image_tag(source, options)
    else
      image_html = image_tag("blank.png", options.merge({"data-href" => path_to_image(source)}))
      image_html << content_tag("noscript") do # Tag to show image when the JS is disabled.
        image_tag(source, options)
      end
    end
    render :inline => image_html
  end
end
