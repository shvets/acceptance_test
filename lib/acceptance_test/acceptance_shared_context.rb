acceptance_test_lambda = lambda do
  attr_reader :acceptance_test

  before :all do
    @acceptance_test = AcceptanceTest.new
  end

  before do
    acceptance_test.before self
  end

  after do
    acceptance_test.after self
  end
end

RSpec.shared_context "AcceptanceTest" do
  self.define_singleton_method(:include_context, acceptance_test_lambda)

  include_context
end



