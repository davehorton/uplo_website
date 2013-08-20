require 'spec_helper'

feature "Search" do
  let!(:users) { create_list(:user, 5) }
  let!(:new_user) { create(:user, :username => "demo", :email => "test@test.com") }
  let!(:product) { create(:product) }
  let!(:another_product) { create(:product, :size => create(:square_size)) }
  let!(:product_option) { create(:product_option, :product_id => product.id, :description => "Borderless") }
  let!(:another_product_option) { create(:product_option, :product_id => another_product.id, :description => "Borderless") }
  let!(:images) { create_list(:real_image, 3) }
  let!(:image) { create(:real_image) }
  let!(:another_image) { create(:real_image) }

  context "browse and spotlight page Users search", :js => true do
    background do
      visit browse_path
    end

    scenario "for all users" do
      select "Users", :from => "filtered_by"
      page.find(".search").click
      page.should have_selector('span', text: "Best Match")
      users.each do |user|
        page.should have_selector('a', text: "#{user.username}")
      end
    end

    scenario "for one specific user with correct username" do
      within("#filtering-search-box") do
        fill_in "query", :with => new_user.username
        select "Users", :from => "filtered_by"
        page.find(".search").click
      end
      page.should have_content("1 User found")
      page.should have_selector('a', text: "#{new_user.username}")
    end

    scenario "for one specific user with username along with punctutaions" do
      within("#filtering-search-box") do
        fill_in "query", :with => "...demo;;;;"
        select "Users", :from => "filtered_by"
        page.find(".search").click
      end
      page.should have_content("1 User found")
      page.should have_selector('a', text: "demo")
    end

    scenario "for one specific user with correct email, it does not find user" do
      within("#filtering-search-box") do
        fill_in "query", :with => new_user.email
        select "Users", :from => "filtered_by"
        page.find(".search").click
      end
      page.should have_content("0 Users found")
      page.should_not have_selector('a', text: "demo")
    end
  end

  context "browse and spotlight page Photos search", :js => true do
    background do
      visit browse_path
    end

    scenario "for all images" do
      select "Users", :from => "filtered_by"
      select "Photos", :from => "filtered_by"
      page.find(".search").click
      page.should have_selector('span', text: "Recent Uploads")
      images.each do |image|
        page.should have_selector("#image-container-#{image.id}")
      end
    end

    scenario "for one specific image" do
      within("#filtering-search-box") do
        fill_in "query", :with => another_image.name
        select "Photos", :from => "filtered_by"
        page.find(".search").click
      end
      page.should have_selector('span', text: "Search")
      page.should have_selector('span', text: "5 Photos found")
      page.should have_selector("#image-container-#{another_image.id}")
    end

    scenario "for one specific image with name along with punctutaions" do
      within("#filtering-search-box") do
        fill_in "query", :with => "...photo;;;;"
        select "Photos", :from => "filtered_by"
        page.find(".search").click
      end
      page.should have_content("5 Photos found")
      page.should have_selector("#image-container-#{another_image.id}")
    end
  end

end
