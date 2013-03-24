class SocialsController < ApplicationController
	def facebook_callback
		@api_key = FACEBOOK_CONFIG["api_key"]
		@secret = FACEBOOK_CONFIG["secret"]
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
	    current_user.update_attribute(:facebook_token, access_token.token)
	    flash[:notice] = "Enabled Facebook"
		rescue Exception => e

		  # You will need this error during development to make progress :)
		  #logger.error(e)
		  #TODO Add logs
      e.to_s.slice!(0)
      paresed_json = ActiveSupport::JSON.decode(e.to_s)
      flash[:error] = paresed_json["error"]["message"]
		end

		redirect_to :controller => :users, :action => :account
	end

	def twitter_callback
		@consumer_key = TWITTER_CONFIG["consumer_key"]
    @consumer_secret = TWITTER_CONFIG["consumer_secret"]
		@options = {:site => "http://api.twitter.com", :request_endpoint => "http://api.twitter.com"}

    begin
	    consumer = OAuth::Consumer.new(@consumer_key, @consumer_secret, @options)
	    access_token = OAuth::RequestToken.new(consumer, session[:token], session[:secret]).
	                                         get_access_token(:oauth_verifier => params[:oauth_verifier])

	    if current_user.update_attributes({:twitter_token => access_token.token,
	    												 :twitter_secret_token => access_token.secret})
				flash[:notice] = "Enabled Twitter"
			else
				flash[:notice] = current_user.errors.full_messages.to_sentence
			end
    rescue OAuth::Unauthorized
      flash[:notice] = "Cannot authorize Twitter"
    end

		redirect_to :controller => :users, :action => :account
	end

	def tumblr_callback
		request_token = session[:request_token]
		begin
			access_token = request_token.get_access_token({:oauth_verifier => params[:oauth_verifier]})
			if current_user.update_attributes({:tumblr_token => access_token.token,
	    												 :tumblr_secret_token => access_token.secret})
				flash[:notice] = "Enabled Tumblr"
			else
				flash[:notice] = current_user.errors.full_messages.to_sentence
			end
		rescue Exception => e
			flash[:notice] = "Cannot authorize Tumblr"
		end

		redirect_to :controller => :users, :action => :account
	end

	def flickr_callback
		request_token = session[:request_token]
		begin
    	access_token = flickr.get_access_token(request_token['oauth_token'], request_token['oauth_token_secret'], params[:oauth_verifier])

			if current_user.update_attributes({:flickr_token => access_token['oauth_token'],
	    												 :flickr_secret_token => access_token['oauth_token_secret']})
				flash[:notice] = "Enabled Flickr"
			else
				flash[:notice] = current_user.errors.full_messages.to_sentence
			end
		rescue Exception => e
			flash[:notice] = "Cannot authorize Flickr #{e.message} #{access_token.inspect}"
		end

		redirect_to :controller => :users, :action => :account
	end

	# params
	# image_id
	# social[:message]
	# social[:type_social]

	def share
		social = params[:social]
		@message = social[:message]
		link = nil
		photo = nil
		medium_photo = nil
		description = nil
		redirect_link = '/'
		if (params[:gallery_id])
			gallery = Gallery.find_by_id params[:gallery_id]
			if (gallery)
				link = url_for(:controller => :galleries, :action => :public, :gallery_id => gallery.id, :only_path => false)
				photo = gallery_cover_image_url(gallery)
				medium_photo = gallery_cover_image_url(gallery, :medium)
			end
		elsif (params[:image_id])
			img = Image.find_by_id params[:image_id]
			if (img)
				link = public_image_path(img)
				photo = img.url(:thumb)
				medium_photo = img.url(:medium)
				description = img.description
			end
		end

		if (link)
			if (social[:type_social] == 'facebook')
				facebook_share(link, photo, description)
			end
			if (social[:type_social] == 'twitter')
				twitter_share(link)
			end
			if (social[:type_social] == 'tumblr')
				tumblr_share(link, medium_photo)
			end
			if (social[:type_social] == 'flickr')
				flickr_share(link, medium_photo)
			end
		else
			flash[:notice] = "Cannot share the link at this moment"
		end

		if (params[:gallery_id])
			go_to_galleries_url
		elsif (params[:image_id])
			go_to_browser_image_url(params[:image_id])
		else
			render_not_found
		end
	end


	protected

		# params
		# image_id
		# message

		def facebook_share(link, photo, description)
			if (current_user.facebook_token)
				user = FbGraph::User.me(current_user.facebook_token)
				begin
					user.feed!(
					  :message => @message,
					  :picture => photo,
					  :link => link,
					  :name => 'Shared from UPLO',
					  :caption => "#{DOMAIN}",
					  :description => description
					)
					flash[:notice] = "Post successful"
				rescue FbGraph::Unauthorized => e
					case e.message
				  when /Duplicate status message/
				    flash[:notice] = "Duplicated message"
				  when /Error validating access token/
				    current_user.update_attribute(:facebook_token, "")
				    flash[:notice] = "Could not authenticate you with Facebook, please try again."
						redirect_to :controller => :users, :action => :account and return
				  else
				    flash[:notice] = "Cannot share the link at this moment: #{e.message}"
				  end
				rescue Exception => e
					flash[:notice] = "Cannot share the link at this moment: #{e.message}"
				end
			else
				flash[:notice] = "You must enable Facebook sharing"
				redirect_to :controller => :users, :action => :account and return
			end
		end

		# params image_id
		# params message
		def twitter_share(link)
			if (current_user.twitter_token)
				@consumer_key = TWITTER_CONFIG["consumer_key"]
	   	 	@consumer_secret = TWITTER_CONFIG["consumer_secret"]

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
		    	message = (@message.to_s << " - " << link)
		      client.update(message)
		      flash[:notice] = "Post tweet successful"
		    rescue Exception => e
		      flash[:notice] = "Unable to send to Twitter: #{e.to_s}"
		    end

			else
				flash[:notice] = "You must enable Twitter sharing"
				redirect_to :controller => :users, :action => :account and return
			end
		end

		# params image_id
		def tumblr_share(link, medium_photo)
			if (current_user.tumblr_token)
				@consumer_key = TUMBLR_CONFIG["consumer_key"]
	   	 	@consumer_secret = TUMBLR_CONFIG["consumer_secret"]

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
							message = (@message.to_s << "<p>Shared from <a href='http://#{DOMAIN}'>UPLO</a></p>")

							response = access_token.request(:post, "/v2/blog/#{base_name}/post",
																		{:type => "photo" ,:caption => message, :link => link, :source => medium_photo})
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
				flash[:notice] = "You must enable Tumblr sharing"
				redirect_to :controller => :users, :action => :account and return
			end

		end

		def flickr_share(link, photo)
			require 'tempfile'
			if (current_user.flickr_token)
				@api_key = FLICKR_CONFIG["api_key"]
	      @secret_key = FLICKR_CONFIG["secret"]

	      FlickRaw.api_key=@api_key
	      FlickRaw.shared_secret=@secret_key

	      flickr.access_token = current_user.flickr_token
				flickr.access_secret = current_user.flickr_secret_token

 				begin
 					prefix = 'abc.jpg'
 					tempfile = Tempfile.open(prefix, Rails.root.join('tmp'))
 					file = File.open(tempfile.path, 'wb')
 					uri = URI.parse(photo)
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

					if flickr.upload_photo tempfile.path, :title => @message, :description => "from <a href='#{link}' rel='nofollow'>UPLO</a>"
						flash[:notice] = "Send photo successful"
					else
						"Unable to send to Flickr"
					end
				rescue Exception => e
					flash[:notice] = "Unable to send to Flickr: #{e.to_s}"
				end
			else
				flash[:notice] = "You must enable Flickr sharing"
				redirect_to :controller => :users, :action => :account and return
			end
		end

		def go_to_browser_image_url(id)
			redirect_to browse_image_path(id)
		end

		def go_to_galleries_url
			redirect_to :controller => :galleries, :action => :index
		end

		def gallery_cover_image_url(gallery, type = :thumb)
	    img_url = "#{root_url}/assets/gallery-thumb-180.jpg" # Default image.
	    image = gallery.cover_image
	    if image && !image.removed? && (!image.flagged?)
	      img_url = image.url(type)
	    end

	    img_url
	  end
end