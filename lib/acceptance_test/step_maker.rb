module StepMaker

  attr_reader :input

  def initialize
    @input = {}
  end

  def step title
    values = []

    params = title.gsub(/:\w+/)

    params.each do |param|
      key = param.gsub(":", "").to_sym
      values << input[key] if input[key]
    end

    yield *values if block_given?
  end

end