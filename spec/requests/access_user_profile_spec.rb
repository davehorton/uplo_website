require 'spec_helper'

feature "Accessing User Profile Page" do
  let!(:product) { create(:product) }
  let!(:product) { create(:product, :size => create(:square_size)) }
  let!(:user) { create(:user, :username => "test_user") }
  let!(:gallery) { create(:gallery, :user_id => user.id, :name => "nature gallery") }
  let!(:image) { create(:real_image, :gallery => gallery) }

  context "without login" do
    background do
      visit profile_user_path(:user_id => user.id)
    end

    scenario "profile information" do
      page.should have_selector('a', :text => "#{user.fullname}")
      page.should have_selector('div', text: "Photo")
      page.should have_selector('div', text: "Gallery")
      page.should have_selector('div', text: "Likes")
      page.should have_selector('div', text: "Followers")
      page.should have_selector('div', text: "Following")
      page.should have_selector("#btn-follow")
    end

    scenario "view all" do
      page.should have_selector('a', text: "+ VIEW ALL")
    end

    scenario "photos" do
      page.should have_selector('div', text: "#{user.username}'s Photo")
      page.should have_selector('div', text: "(#{user.images.count})")
      page.should have_selector("#image-container-#{image.id}")
    end

    scenario "galleries", :js => true do
      page.should have_selector('div', text: "#{user.username}'s Gallery")
      page.should have_selector('div', text: "(#{user.galleries.count})")
      within("#galleries-section .head") do
        page.find(".title").click
      end
      within("div#endless-pages #gallery-container-#{gallery.id}") do
        page.should have_selector(".image-container")
      end
    end
  end

  context "with login" do
    background do
      login_user(user)
      visit profile_path
    end

    scenario "profile information" do
      page.should have_selector('div', text: "Photo")
      page.should have_selector('div', text: "Gallery")
      page.should have_selector('div', text: "Likes")
      page.should have_selector('div', text: "Followers")
      page.should have_selector('div', text: "Following")
    end

    scenario "edit profile information", :js => true do
      within("div#user-section .info .edit-pane") do
        page.should have_selector('div', text: "Edit Profile Information")
        page.find(".text").click
      end
      within("div#edit-profile-info-popup .header") do
        page.should have_selector('div', text: "Edit Your Profile Information")
      end
      within("div#edit-profile-info-popup  #frm-edit-profile-info") do
        page.should have_selector("#user_first_name")
        page.should have_selector("#user_last_name")
        page.should have_selector("#user_email")
        fill_in "user_job", :with => "Canada"
      end
      within("div#edit-profile-info-popup  .container .button-container") do
        page.find("#btn-update").click
      end
      page.should have_selector('div', text: "Canada")
      page.should have_content("Profile was successfully updated.")
    end

    scenario "edit link" do
      within("div#photos-section .head") do
        page.should have_selector('a', text: "Edit")
        page.find(".edit-pane").click
      end
      current_path.should == galleries_edit_images_path
    end

    scenario "photos" do
      page.should have_selector('div', text: "Your Photo")
      page.should have_selector('div', text: "(#{user.images.count})")
      page.should have_selector("#image-container-#{image.id}")
    end

    scenario "galleries", :js => true do
      page.should have_selector('div', text: "Your Gallery")
      page.should have_selector('div', text: "(#{user.galleries.count})")
      within("#galleries-section .head") do
        page.find(".title").click
      end
      within("div#gallery-container-#{gallery.id} .gallery-info") do
        page.should have_selector('div', text: "nature gallery")
        page.should have_selector('div', text: "#{gallery.images.count} Image")
      end
    end
  end

end
