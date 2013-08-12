require 'spec_helper'

feature "Home Pages" do
  let!(:another_product) { create(:product, :size => create(:square_size)) }
  let!(:product) { create(:product)}
  let!(:user) { create(:user)}
  let!(:image) { create(:real_image, :promoted => true)}

  context "home page" do
    background do
      visit root_path
    end

    scenario "header has correct items" do
      page.should have_selector('a', text: 'Explore')
      page.should have_selector('a', text: 'Spotlight')
      page.should have_link("Login-btn", href: "#{signin_path}")
      page.should have_css('.app-btn')
    end

    scenario "it should show spotlight and recent uploads" do
      page.should have_selector('div', text: 'Spotlight Images')
      page.should have_selector('div', text: 'Recent Uploads')
    end
  end

  context "browse page" do
    background do
      visit browse_path
    end

    scenario "header has correct items" do
      page.should have_selector('a', text: 'Explore')
      page.should have_selector('a', text: 'Spotlight')
      page.should have_link("Login-btn", href: "#{signin_path}")
      page.should have_css('.app-btn')
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
      visit spotlight_path
    end

    scenario "header has correct items" do
      page.should have_selector('a', text: 'Explore')
      page.should have_selector('a', text: 'Spotlight')
      page.should have_link("Login-btn", href: "#{signin_path}")
      page.should have_css('.app-btn')
    end

    scenario "showing spotlight images" do
      page.should have_selector('span', text: 'Browse')
      page.should have_selector('span', text: 'Spotlight Images')
      page.should have_selector("#image-container-#{image.id}")
      page.should have_link(image.name, href: "#{browse_image_path(image.id)}")
    end
  end

end
