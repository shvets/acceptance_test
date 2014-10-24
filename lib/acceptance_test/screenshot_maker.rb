class ScreenshotMaker
  attr_accessor :basedir

  def initialize basedir
    @basedir = basedir
  end

  def make page, options
    page.save_screenshot(screenshot_path(options))
  end

  def screenshot_path options
    File.expand_path("#{basedir}/#{screenshot_name(options)}")
  end

  def screenshot_name options
    filename = File.basename(options[:file_path])
    line_number = options[:line_number]

    name = filename
    name += "-#{line_number}" if line_number

    "#{name}.png"
  end

  def screenshot_url options
    "file:///#{screenshot_path(options)}"
  end

end
