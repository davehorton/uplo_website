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
    "http://pinterest.com/pin/create/button/?url=#{CGI.escape(image_public_url)}&description=#{image_desc(image)}&media=#{CGI.escape(image.url(:thumb))}"
  end

  def image_desc(image)
    CGI.escape("Share from UPLO: #{image.name.humanize} by #{image.user.fullname}")
  end

  # TODO: move to ability class
  def can_promote_image?(image, user = nil)
    user ||= current_user
    (current_user.admin? && image.gallery_is_public? && !image.promoted? && !image.removed? && !image.flagged?)
  end

  def size_options(sizes, selected_size=nil)
    opts = []
    sizes.each do |size|
      opts << [ size.to_name, size.id, {
        :'data-min-height' => size.minimum_recommended_resolution[:h],
        :'data-min-width' => size.minimum_recommended_resolution[:w],
        :'data-ratio' => size.aspect_ratio } ]
    end

    options_for_select(opts, selected_size)
  end

  def product_option_options(product_options, selected_option=nil)
    opts = []
    product_options.each do |po|
      opts << [ po.description, po.id, { :'data-border_top_bottom' => po.border_top_bottom, :'data-border_left_right' => po.border_left_right } ]
    end

    options_for_select(opts, selected_option)
  end

  def image_name_with_default
    @image.name + ' | ' + t('common.site_title')
  end

  def image_description
    @image.description
  end

end
