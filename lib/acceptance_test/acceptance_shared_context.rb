shared_context "AcceptanceTest" do

  attr_reader :acceptance_test

  before :all do
    @acceptance_test = AcceptanceTest.new
  end

  before do
    @acceptance_test.before self
  end

  after do
    @acceptance_test.after self
  end

end
