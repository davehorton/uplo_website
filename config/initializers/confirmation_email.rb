module Devise::Models::Confirmable
 
	# Override Devise's own method. This one is called only on user creation, not on subsequent address modifications.
	def send_on_create_confirmation_instructions
		DeviseMailer.send_confirmation_email(self).deliver
	end
 
end