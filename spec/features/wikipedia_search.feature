Feature: Using Wikipedia

  Background: within wikipedia.com context
    Given I am within wikipedia.com

  @selenium
  @wikipedia
  Scenario: Searching with selenium for a term with submit

    Given I am on wikipedia.com
    When I enter word "Capybara"
    And I click submit button
    Then I should see results: "Capybara"

  @webkit
  Scenario: Searching with selenium for a term with submit

    Given I am on wikipedia.com
    When I enter word "Capybara"
    And I click submit button
    Then I should see results: "Capybara"

  @poltergeist
  Scenario: Searching with selenium for a term with submit

    Given I am on wikipedia.com
    When I enter word "Capybara"
    And I click submit button
    Then I should see results: "Capybara"
