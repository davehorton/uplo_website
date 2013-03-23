class Mailchimp

	UPLO_LIST_ID = "1fd9693012"

	def self.subscribe_user(user_id)
		user = User.unscoped.find(user_id)
		gibbon.list_subscribe({
			:id => UPLO_LIST_ID,
			:email_address => user.email,
			:merge_vars => {:FName => user.first_name, :LNAME => user.last_name}})
	end

	protected

		def self.gibbon
			@gibbon = Gibbon.new if @gibbon.nil?
			return @gibbon
		end
end