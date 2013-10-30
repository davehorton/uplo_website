require 'spec_helper'

feature "Gallery" do
  let!(:user) { create(:user, :username => "test_user") }
  let!(:old_gallery) { create(:gallery, :user_id => user.id) }

  background do
    login_user(user)
  end

  scenario "creating with correct credentials", :js => true do
    visit galleries_path
    page.should have_selector('div', text: "My Galleries")
    page.should have_selector("#gallery-container-#{old_gallery.id}")
    page.should have_selector('div', text: "#{old_gallery.name}")
    within("#top") do
      click_link "new-gallery"
    end
    within("#frm-edit-gallery") do
      fill_in "gallery_name", :with => "aaa"
      fill_in "gallery_description", :with => "beauty"
    end
    within("#frm-edit-gallery #button-container") do
      expect { page.find("#btn-gallery-save").click }.to change(Gallery, :count).by(1)
    end
    page.should have_selector('div', text: "My Gallery")
    page.should have_link("Edit Gallery Info", href: "#")
    page.should have_selector('a', text: "Delete Gallery")
  end

  scenario "creating without name", :js => true do
    visit galleries_path
    within("#top") do
      click_link "new-gallery"
    end
    within("#frm-edit-gallery") do
      fill_in "gallery_name", :with => ""
    end
    within("#frm-edit-gallery #button-container") do
      page.find("#btn-gallery-save").click
    end
    current_path.should == galleries_path
    page.should have_content("Name can't be blank")
  end

  scenario "editing", :js => true do
    visit edit_images_gallery_path(old_gallery.id)
    click_link "edit-gallery"
    within("#edit-gallery-popup .header") do
      page.should have_selector('div', text: "Edit Your Gallery Infomation")
    end
    within("#frm-edit-gallery") do
      fill_in "gallery_name", :with => "my new gallery"
      fill_in "gallery_description", :with => "a thing of beauty"
    end
    within("#edit-gallery-popup #button-container") do
       page.find("#btn-gallery-save").click
     end
    within("#gallery_selector_id-button") do
      page.should have_selector('span', text: "my new gallery")
    end
  end
end


