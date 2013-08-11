module IntegrationHelpers

  def login_user(user = nil)
    visit signin_path
    within("#new_user") do
      fill_in "user_login", :with => user.email
      fill_in "user_password", :with => user.password
      click_on "login"
    end
  end

end
