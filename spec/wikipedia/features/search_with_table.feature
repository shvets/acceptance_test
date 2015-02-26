Feature: Using Wikipedia

  @search_with_table
  Scenario: Searching with selenium for a term with submit (embedded data)

    Given I am on wikipedia.com
    And I have the following data:
      | key     | value    |
      | keyword | Capybara |
      | result  | Hydrochoerus hydrochaeris |
    Then "keyword" should be "Capybara"
    And "result" should be "Hydrochoerus hydrochaeris"

    When I enter word <keyword>
    And I click submit button
    Then I should see <result>
