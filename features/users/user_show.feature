Feature: Show Users
  As a visitor to the website
  I want to see registered users listed on the homepage
  so I can know if the site has users
    
    @javascript
    Scenario: Viewing users
      Given I exist as a user
        And I am logged in
      When I go to my profile page
      Then I should see my profile information
