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

  # TODO: move to ability class
  def can_promote_image?(image, user = nil)
    user ||= current_user
    (user.admin? && !image.promoted? && !image.removed? && !image.flagged?)
  end

  def size_options(sizes, selected_size=nil)
    opts = []
    sizes.each do |size|
      opts << [ size.to_name, size.id, { :'data-min-width' => size.minimum_recommended_resolution[:w], :'data-min-height' => size.minimum_recommended_resolution[:h] } ]
    end

    options_for_select(opts, selected_size)
  end

  def image_name_with_default
    @image.name + ' | ' + t('common.site_title')
  end

  def image_description
    @image.description
  end

end
