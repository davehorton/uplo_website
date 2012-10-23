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
		get_auth_info
		@consumer_key = @twitter_cfg["consumer_key"]
    @consumer_secret = @twitter_cfg["consumer_secret"]
		@options = {:site => "http://api.twitter.com", :request_endpoint => "http://api.twitter.com"}
      
    begin
	    consumer = OAuth::Consumer.new(@consumer_key, @consumer_secret, @options)
	    access_token = OAuth::RequestToken.new(consumer, session[:token], session[:secret]).
	                                         get_access_token(:oauth_verifier => params[:oauth_verifier])

	    @user = current_user
	    if @user.update_attributes({:twitter_token => access_token.token, 
	    												 :twitter_secret_token => access_token.secret})
				flash[:notice] = "Enabled Twitter"
			else
				flash[:notice] = @user.errors.full_messages.to_sentence
			end
    rescue OAuth::Unauthorized
      flash[:notice] = "Invalid OAuth token, unable to connect to twitter"
    end

		redirect_to :controller => :users, :action => :profile
	end

	def tumblr_callback
		request_token = session[:request_token]
		begin
			access_token = request_token.get_access_token({:oauth_verifier => params[:oauth_verifier]})
			@user = current_user

			if @user.update_attributes({:tumblr_token => access_token.token, 
	    												 :tumblr_secret_token => access_token.secret})
				flash[:notice] = "Enabled Tumblr"
			else
				flash[:notice] = @user.errors.full_messages.to_sentence
			end
		rescue Exception => e
			flash[:notice] = "Cannot authorize Tumblr"
		end

		redirect_to :controller => :users, :action => :profile
	end

	def flickr_callback
		request_token = session[:request_token]
		begin
    	access_token = flickr.get_access_token(request_token['oauth_token'], request_token['oauth_token_secret'], params[:oauth_verifier])

			@user = current_user
			puts access_token.inspect
			if @user.update_attributes({:flickr_token => access_token['oauth_token'], 
	    												 :flickr_secret_token => access_token['oauth_token_secret']})
				flash[:notice] = "Enabled Flickr"
			else
				flash[:notice] = @user.errors.full_messages.to_sentence
			end
		rescue Exception => e
			flash[:notice] = "Cannot authorize Flickr #{e.message} #{access_token.inspect}"
		end

		redirect_to :controller => :users, :action => :profile
	end
	
	# params 
	# image_id
	# social[:message]
	# social[:type_social]

	def share
		social = params[:social]
		@message = social[:message]
		if (social[:type_social] == 'facebook')
			facebook_share
		end
		if (social[:type_social] == 'twitter')
			twitter_share
		end
		if (social[:type_social] == 'tumblr')
			tumblr_share
		end
		if (social[:type_social] == 'flickr')
			flickr_share
		end
	end


	protected

		# params 
		# image_id
		# message

		def facebook_share
			if (current_user.facebook_token)
				img = Image.find_by_id params[:image_id]
				if (img)
					user = FbGraph::User.me(current_user.facebook_token)
					begin 
						user.feed!(
						  :message => @message,
						  :picture => img.data.url(:thumb),
						  :link => url_for(:controller => :images, :action => :public, :id => img.id, :only_path => false),
						  :name => 'Shared from UPLO',
						  :caption => "uplo.heroku.com",
						  :description => img.description
						)
						flash[:notice] = "Post successful"
					rescue FbGraph::Unauthorized => e
						case e.message
					  when /Duplicate status message/
					    flash[:notice] = "Duplicated message"
					  when /Error validating access token/
					    current_user.update_attribute(:facebook_token, "")
					    flash[:notice] = "There is some problem with authetication, please re-enable your Facebook"
							redirect_to :controller => :users, :action => :profile and return
					  else
					    flash[:notice] = "Cannot share the link at this moment: #{e.message}"
					  end
					rescue Exception => e
						flash[:notice] = "Cannot share the link at this moment: #{e.message}"
					end
				else
					render_not_found
				end
			else
				flash[:notice] = "You must enable Facebook sharing"
				redirect_to :controller => :users, :action => :profile and return
			end
			go_to_browser_image_url(img)
		end

		# params image_id
		# params message
		def twitter_share
			if (current_user.twitter_token)
				get_auth_info
				@consumer_key = @twitter_cfg["consumer_key"]
	   	 	@consumer_secret = @twitter_cfg["consumer_secret"]

				img = Image.find_by_id params[:image_id]
				if (img)
					Twitter.configure do |config|
			      config.consumer_key = @consumer_key
			      config.consumer_secret = @consumer_secret
			      config.oauth_token = current_user.twitter_token
			      config.oauth_token_secret = current_user.twitter_secret_token
			    end
			    client = Twitter::Client.new(
					  :oauth_token => current_user.twitter_token,
					  :oauth_token_secret => current_user.twitter_secret_token
					)
			    begin
			    	message = (@message.to_s << " - " << url_for(:controller => :images, :action => :public, :id => img.id, :only_path => false))
			      client.update(message)
			      flash[:notice] = "Post tweet successful"
			    rescue Exception => e
			      flash[:notice] = "Unable to send to Twitter: #{e.to_s}"
			    end

				else
					return render_not_found
				end
			else
				flash[:notice] = "You must enable Twitter sharing"
				redirect_to :controller => :users, :action => :profile and return
			end
			go_to_browser_image_url(img)
		end

		# params image_id
		def tumblr_share
			if (current_user.tumblr_token)
				get_auth_info
				@consumer_key = @tumblr_cfg["consumer_key"]
	   	 	@consumer_secret = @tumblr_cfg["consumer_secret"]

				img = Image.find_by_id params[:image_id]
				if (img)

					consumer = OAuth::Consumer.new @consumer_key, @consumer_secret, :site => "http://api.tumblr.com"
					token_hash = { :oauth_token => current_user.tumblr_token,
				                 :oauth_token_secret => current_user.tumblr_secret_token
				               }
	 				access_token = OAuth::AccessToken.from_hash(consumer, token_hash )
	 				begin
						response = access_token.request(:post, "/v2/user/info")
						user_info = JSON.parse(response.body)
						status = user_info["meta"]["status"]
						if (status == 200)
							if (user_info["response"]["user"]["blogs"].count > 0)
								base_name = user_info["response"]["user"]["blogs"][0]["name"] << ".tumblr.com"
							else
								flash[:notice] = "There is no blog to post photo"
							end

							begin
								url = url_for(:controller => :images, :action => :public, :id => img.id, :only_path => false)
								message = (@message.to_s << "<p>Shared from <a href='http://uplo.heroku.com'>UPLO</a></p>")

								response = access_token.request(:post, "/v2/blog/#{base_name}/post", 
																			{:type => "photo" ,:caption => message, :link => url, :source => img.data.url(:medium)})
								result = JSON.parse(response.body)
								status = result["meta"]["status"]
								if (status == 201)
									flash[:notice] = "Post blog successful"
								else
									flash[:notice] = result["meta"]["msg"]
								end
							rescue Exception => e
								flash[:notice] = "Unable to send to Tumblr: #{e.to_s}"
							end
						else
							flash[:notice] = "The Tumblr blog not available"
						end
					rescue Exception => e
						flash[:notice] = "Unable to send to Tumblr: #{e.to_s}"
					end
				else
					render_not_found
				end
			else
				flash[:notice] = "You must enable Tumblr sharing"
				redirect_to :controller => :users, :action => :profile and return
			end
			go_to_browser_image_url(img)
			
		end

		def flickr_share
			require 'tempfile'
			if (current_user.flickr_token)
				get_auth_info

				img = Image.find_by_id params[:image_id]
				if (img)

					@api_key = @flickr_cfg["api_key"]
		      @secret_key = @flickr_cfg["secret"]

		      FlickRaw.api_key=@api_key
		      FlickRaw.shared_secret=@secret_key

		      flickr.access_token = current_user.flickr_token
					flickr.access_secret = current_user.flickr_secret_token

	 				begin
	 					prefix = 'abc.jpg'
	 					tempfile = Tempfile.open(prefix, Rails.root.join('tmp'))
	 					file = File.open(tempfile.path, 'wb')
	 					uri = URI.parse(img.data.url(:medium))
	 					Net::HTTP.start(uri.host) do |http|
						  begin
						    http.request_get(uri.request_uri) do |response|
						      response.read_body do |segment|
						      	file.write(segment)
						      end
						    end
						  ensure
						  	file.close
						  end
						end

						if flickr.upload_photo tempfile.path, :title => @message, :description => "from <a href='#{img.public_link}' rel='nofollow'>UPLO</a>"
							flash[:notice] = "Send photo successful"
						else
							"Unable to send to Flickr"
						end
					rescue Exception => e
						flash[:notice] = "Unable to send to Flickr: #{e.to_s}"
					end
				else
					render_not_found
				end
			else
				flash[:notice] = "You must enable Flickr sharing"
				redirect_to :controller => :users, :action => :profile and return
			end
			go_to_browser_image_url(img)
		end

		def go_to_browser_image_url(img)
			redirect_to :controller => :images, :action => :browse, :id => img.id
		end
end