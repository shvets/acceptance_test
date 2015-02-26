Feature: Using Wikipedia

  @search_with_scenario_outline
  Scenario Outline: Searching with selenium for a term with submit (external data)

    Given I am on wikipedia.com
    When I enter word <keyword>
    And I click submit button
    Then I should see "<result>"

  Examples:
    | file:data.yml, key:test2 |
