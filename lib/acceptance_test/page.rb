class Page

  attr_reader :page_set

  def initialize page_set
    @page_set = page_set
  end

  def session
    page_set.session
  end

  def with_session &code
    session.instance_eval &code
  end

end
