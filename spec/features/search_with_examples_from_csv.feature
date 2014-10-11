Feature: Using Wikipedia

  Background: within wikipedia.com context
    Given I am within wikipedia.com

  @selenium
  @search_with_examples_from_csv
  Scenario Outline: Searching with selenium for a term with submit (embedded data)

    Given I am on wikipedia.com
    When I enter word <keyword>
    And I click submit button
    Then I should see "<result>"

  Examples:
    | keyword  | result |
    | Capybara | Hydrochoerus hydrochaeris |
    | Wombat   | quadrupedal marsupials    |
    | Echidna  | Tachyglossidae |

  @selenium
  @search_with_examples_from_csv
  Scenario Outline: Searching with selenium for a term with submit (external data)

    Given I am on wikipedia.com
    When I enter word <keyword>
    And I click submit button
    Then I should see "<result>"

  Examples:
    | keyword | result |
    | file:spec/data.csv ||