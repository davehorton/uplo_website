class AuthenticationsController < ApplicationController
  skip_before_filter :authenticate_user!

  def create
    omniauth = request.env["omniauth.auth"]
    #Rails.logger.debug omniauth.to_yaml
    #return render :text => omniauth.to_yaml
    authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
    if authentication
      flash[:notice] = "Signed in successfully."
      #sign_in_and_redirect(:user, authentication.user)
      sign_in(:user, authentication.user)
      redirect_to controller: 'home', action: 'index'
    elsif current_user
      current_user.authentications.create!(:provider => omniauth['provider'], :uid => omniauth['uid'], :oauth_token => omniauth['credentials']['token'], :oauth_secret => omniauth['credentials']['secret'])
      flash[:notice] = "Authentication successful."
      #redirect_to authentications_url
      redirect_to controller: 'users', action: 'account'
    elsif omniauth['provider'] == 'facebook' && user = User.find_by_email(omniauth['info']['email'])
      user.authentications.create!(:provider => omniauth['provider'], :uid => omniauth['uid'], :oauth_token => omniauth['credentials']['token'], :oauth_secret => omniauth['credentials']['secret'])
      flash[:notice] = "Signed in successfully."
      sign_in(:user, user)
      redirect_to controller: 'home', action: 'index'
    else
      user = User.new
      user.apply_omniauth(omniauth)
      if user.save
        flash[:notice] = "Signed in successfully."
        sign_in_and_redirect(:user, user)
      else
        session[:omniauth] = omniauth.except('extra')
        redirect_to new_user_registration_url
      end
    end
  end

  def destroy
    @authentication = current_user.authentications.find(params[:id])
    @authentication.destroy
    flash[:notice] = "Successfully destroyed authentication."
    redirect_to controller: 'users', action: 'account'
  end
end
