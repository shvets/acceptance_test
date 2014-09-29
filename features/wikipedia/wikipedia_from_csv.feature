Feature: Using Wikipedia

  Background: within wikipedia.com context
    Given I am within wikipedia.com

  @selenium
  Scenario Outline: Searching with selenium for a term with submit

    Given I am on wikipedia.com
    When I enter word <keyword>
    And click submit button
    Then I should see keyword results: <keyword>

    Examples:
      | file |
      | features/wikipedia/support/data.csv |