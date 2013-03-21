class ImageObserver < ActiveRecord::Observer
  def after_save(image)
    update_avatar if image.owner_avatar_changed?
  end

  private

    def update_avatar(image)
      if image.owner_avatar?
        if profile_image = image.user.profile_images.where(link_to_image: image.id).first
          profile_image.set_as_default
        else
          image.user.profile_images.create(link_to_image: image.id, avatar: open(url(:thumb)))
        end
      else
        # TODO: choose a different profile image
      end
    end
end
