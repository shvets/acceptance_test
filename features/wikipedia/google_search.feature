Feature: Using Google

  Background: within wikipedia.com context
    Given I am within wikipedia.com

  @selenium
  Scenario: Searching with selenium for a term with submit

    Given I am on wikipedia.com
    When I enter "Capybara"
    And click submit button
    Then I should see results: "Capybara"
