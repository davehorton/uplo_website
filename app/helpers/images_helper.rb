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
    "http://pinterest.com/pin/create/button/?url=#{CGI.escape(image_public_url)}&description=#{"Share from UPLO: " + image.name}&media=#{CGI.escape(image.data.url(:spotlight_thumb))}"
  end
  
  def can_promote_image?(image, user = nil)
    user ||= current_user
    (current_user.is_admin? && !image.is_promoted? && !image.is_removed? && !image.is_flagged?)
  end
  
end
