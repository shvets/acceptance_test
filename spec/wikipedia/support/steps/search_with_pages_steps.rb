require 'steps/common_steps'
require 'wikipedia_pages'

steps_for :search_with_pages do
  include CommonSteps

  def initialize *params
    puts Capybara.current_driver

    super
  end

end
