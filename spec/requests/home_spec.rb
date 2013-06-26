require 'spec_helper'

feature "Home Pages" do

  given(:product) { create(:product)}
  given(:user) { create(:user)}
  given(:image) { create(:image, :promoted => true)}

  context "home page" do
    background do
      visit root_path
    end

    scenario "header has correct items" do
      page.should have_selector('a', text: 'Browse')
      page.should have_selector('a', text: 'Spotlight')
      page.should have_selector('a', text: 'The App')
      page.should have_selector('a', text: 'Sign Up')
      page.should have_selector('a', text: 'Login')
    end

    scenario "it should show spotlight and recent uploads" do
      page.should have_selector('div', text: 'Spotlight Images')
      page.should have_selector('div', text: 'Recent Uploads')
    end
  end

  context "browse page" do
    background do
      product
      user
      image
      visit browse_path
    end

    scenario "header has correct items" do
      page.should have_selector('a', text: 'Browse')
      page.should have_selector('a', text: 'Spotlight')
      page.should have_selector('a', text: 'The App')
      page.should have_selector('a', text: 'Sign Up')
      page.should have_selector('a', text: 'Login')
    end

    scenario "Recently updated content" do
      page.should have_selector('span', text: 'Browse')
      page.should have_selector('span', text: 'Recent Uploads')
      page.should have_selector("#image-container-#{image.id}")
      page.should have_link(image.name, href: "#{browse_image_path(image.id)}")
    end
  end

  context "spotlight page" do
    background do
      image
      visit spotlight_path
    end

    scenario "header has correct items" do
      page.should have_selector('a', text: 'Browse')
      page.should have_selector('a', text: 'Spotlight')
      page.should have_selector('a', text: 'The App')
      page.should have_selector('a', text: 'Sign Up')
      page.should have_selector('a', text: 'Login')
    end

    scenario "showing spotlight images" do
      page.should have_selector('span', text: 'Browse')
      page.should have_selector('span', text: 'Spotlight Images')
      page.should have_selector("#image-container-#{image.id}")
      page.should have_link(image.name, href: "#{browse_image_path(image.id)}")
    end
  end

end
