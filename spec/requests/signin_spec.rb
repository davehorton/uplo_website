require 'spec_helper'

feature "Sign in" do

  given(:user) { create(:user) }

  scenario "with invalid credentials" do
    visit signin_path
    within("#new_user") do
      fill_in "Login", :with => user.username
      fill_in "Password", :with => "123456"
      click_on "login"
    end
    current_path.should_not == root_path
    page.should have_selector("div", :text => "Invalid email or password")
  end

  scenario "with valid credentials" do
    login_user(user)
    current_path.should == root_path
  end

end
