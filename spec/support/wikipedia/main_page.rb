class MainPage < Page
  def visit_page root
    session.visit root
  end

  def enter_search_request request
    session.fill_in "searchInput", :with => request
  end

  def click_search_button
    session.find(".formBtn", match: :first).click
  end
end