Feature: Using Wikipedia

  Background: within wikipedia.com context
    Given I am within wikipedia.com

  @selenium
  @search_with_pages
  Scenario: Searching with selenium for a term with submit

    Given I am on wikipedia.com
    When I enter word "Capybara"
    And I submit request
    Then I should see "Capybara"
