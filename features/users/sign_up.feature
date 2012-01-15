Feature: Sign up
  In order to get access to protected sections of the site
  As a user
  I want to be able to sign up

    Background:
      Given I am not logged in

    @javascript
    Scenario: User signs up with valid data
      When I sign up with valid user data
      Then I should see a succesfull sign up message
    
    # All these commented scenarios will fail in most of modern browsers.
    #@javascript
    #Scenario: User signs up with invalid email
      #When I sign up with an invalid email
      #Then I should see an invalid email message
#
    #@javascript
    #Scenario: User signs up without password
      #When I sign up without a password
      #Then I should see a missing password message
#
    #@javascript
    #Scenario: User signs up without password confirmation
      #When I sign up without a confirmed password
      #Then I should see a missing password confirmation message

    @javascript
    Scenario: User signs up with mismatched password and confirmation
      When I sign up with a mismatched password confirmation
      Then I should see a mismatched password message

