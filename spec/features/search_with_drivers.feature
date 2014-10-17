Feature: Using Wikipedia

  Background: within wikipedia.com context
    Given I am within wikipedia.com

  @selenium
  @search_with_drivers
  Scenario: Searching with selenium for a term with submit

    Given I am on wikipedia.com
    When I enter word "Capybara"
    And I click submit button
    Then I should see "Hydrochoerus hydrochaeris"

  @webkit
  @search_with_drivers
  Scenario: Searching with selenium for a term with submit

    Given I am on wikipedia.com
    When I enter word "Capybara"
    And I click submit button
    Then I should see "Hydrochoerus hydrochaeris"

  @poltergeist
  @search_with_drivers
  Scenario: Searching with selenium for a term with submit

    Given I am on wikipedia.com
    When I enter word "Capybara"
    And I click submit button
    Then I should see "Hydrochoerus hydrochaeris"
