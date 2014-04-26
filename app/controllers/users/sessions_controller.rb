class Users::SessionsController < Devise::SessionsController
  def index
    super
    @authentications = current_user.authentications if current_user
  end
end
