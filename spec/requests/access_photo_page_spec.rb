require 'spec_helper'

feature "Accessing Photo Page" do
  let!(:product) { create(:product) }
  let!(:another_product) { create(:product, :size => create(:square_size)) }
  let!(:product_option) { create(:product_option, :product_id => product.id, :description => "Borderless") }
  let!(:another_product_option) { create(:product_option, :product_id => another_product.id, :description => "Borderless") }
  let!(:image) { create(:real_image) }
  let!(:related_image) { create(:image, :gallery => image.gallery)}
  let!(:user) { create(:user) }

  context "without login" do
    background do
      visit browse_image_path(image.id)
    end

    scenario "no of likes" do
      page.should have_selector('div', text: "Likes")
      page.should have_selector('div', text: "#{image.image_likes.count}")
    end

    scenario "no of comments and post comment" do
      page.should have_selector('div', text: "Comments")
      page.should have_selector('div', text: "#{image.comments.count}")
      within("#post-comment") do
        page.find(".like-link").click
        current_path.should == new_user_session_path
      end
    end

    scenario "like button" do
      within("#btn-like") do
        page.find(".like-link").click
        current_path.should == new_user_session_path
      end
    end

    scenario "flag button" do
      within("div#center .right .flag") do
        page.find(".like-link").click
        current_path.should == new_user_session_path
      end
    end

    scenario "order button", :js => true do
      page.find(".order").click
      current_path.should == new_user_session_path
    end

    scenario "follow button" do
      within("div#btn-follow") do
        page.find(".like-link").click
        current_path.should == new_user_session_path
      end
    end

    scenario "photo details on the right bar" do
      within("div#right") do
        page.should have_content(image.name.humanize)
      end
      page.should have_selector('a', text: "#{image.user.username}")
      page.should have_selector('div', text: "Uploaded on #{image.created_at.strftime('%m/%d/%Y')}")
    end

    scenario "related images" do
      page.should have_selector("#image-container-#{related_image.id}")
    end
  end

  context "with login" do
    background do
      login_user(user)
      visit browse_image_path(image.id)
    end

    scenario "no of likes" do
      page.should have_selector('div', text: "Likes")
      page.should have_selector('div', text: "#{image.image_likes.count}")
    end

    scenario "no of comments and post comment" do
      page.should have_selector('div', text: "Comments")
      page.should have_selector('div', text: "#{image.comments.count}")
      page.should have_selector('div', text: "Comments and faves")
      fill_in "comment_description", :with => "Hello"
      page.find("#post-comment").click
      page.should have_content("Hello")
    end

    scenario "like button" do
      page.find("#btn-like").click
      page.should have_selector('div', text: "#{image.image_likes.count}")
      current_path.should == browse_image_path(image.id)
    end

    scenario "flag button" do
      page.find(".flag").click
      page.should have_content("Flag for Review")
      within("div#selection_container") do
        page.should have_selector("#rdbtn_nudity")
        choose("rdbtn_nudity")
      end
      current_path.should == browse_image_path(image.id)
    end

    scenario "order button", :flickering, :js => true do
      page.find(".order").click
      current_path.should == order_image_path(image.id)
    end

    scenario "follow button" do
      within("div#right .user-section") do
        page.find("#btn-follow").click
      end
      current_path.should == browse_image_path(image.id)
    end

    scenario "photo details on the right bar" do
      within("div#right") do
        page.should have_content(image.name.humanize)
      end
      page.should have_selector('a', text: "#{image.user.username}")
      page.should have_selector('div', text: "Uploaded on #{image.created_at.strftime('%m/%d/%Y')}")
    end

    scenario "related images" do
      page.should have_selector("#image-container-#{related_image.id}")
    end
  end
end
