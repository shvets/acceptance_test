Feature: Using Wikipedia

  @search_with_pages
  Scenario: Searching with selenium for a term with submit

    Given I am on wikipedia.com
    When I enter word "Capybara"
    And I submit request
    Then I should see "Capybara"
