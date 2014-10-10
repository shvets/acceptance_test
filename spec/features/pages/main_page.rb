require 'acceptance_test/page'

class MainPage < Page
  def visit_home_page
    session.visit('/')
  end

  def enter_word word
     with_session do
       fill_in "searchInput", :with => word
     end
  end

  def submit_request
    session.find(".formBtn", match: :first).click
  end
end