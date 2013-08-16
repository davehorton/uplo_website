class UserFollowObserver < ActiveRecord::Observer
  def after_create(user_follow)
    Rails.logger.debug "blabla"
  end
end
