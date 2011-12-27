class Api::UsersController < Api::BaseController
  def create_user
    info = params
    user = User.new info
    result = {
      :status => true,
      :msg => {}
    }
    unless user.save
      result[:msg] = user.errors 
      result[:status] = false
    end
    render :json => { :info => result }
  end
end
