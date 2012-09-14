class SocialsController < ApplicationController
	before_filter :authenticate_user!
	include SocialModule

	def facebook_callback
		get_auth_info
		@api_key = @facebook_cfg["api_key"]
		@secret = @facebook_cfg["secret"]
		oauth_client = OAuth2::Client.new(@api_key, @secret, {
		    :site => 'https://graph.facebook.com',
		    :token_url => '/oauth/access_token'
		})

		begin

		  access_token = oauth_client.get_token({
		      :client_id => @api_key,
		      :client_secret => @secret,
		      :redirect_uri => url_for(:controller => :socials, :action => :facebook_callback),
		      :code => params[:code],
		      :parse => :query
		  })

		  access_token.options[:mode] = :query
		  access_token.options[:param_name] = :access_token
		  facebook_user_info = access_token.get('/me', {:parse => :json}).parsed
		  @user = current_user
	    @user.update_attribute(:facebook_token, access_token.token)
	    flash[:notice] = "Enabled Facebook"
		rescue Exception => e

		  # You will need this error during development to make progress :)
		  #logger.error(e)
		  #TODO Add logs
      e.to_s.slice!(0)
      paresed_json = ActiveSupport::JSON.decode(e.to_s)
      flash[:error] = paresed_json["error"]["message"]
		end

		redirect_to :controller => :users, :action => :profile
	end

	def twitter_callback
		
	end
end