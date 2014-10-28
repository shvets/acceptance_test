class ScreenshotMaker
  attr_accessor :basedir

  def initialize basedir
    @basedir = basedir
  end

  def make page, options
    name = screenshot_name(File.basename(options[:file_path]), options[:line_number])
    path = File.expand_path("#{basedir}/#{name}")

    page.save_screenshot(path)
  end

  def screenshot_name filename, line_number=nil
    "#{filename}#{line_number ? '-'+line_number : ''}.png"
  end

  def screenshot_url options
    file_path = options[:file_path]

    if file_path =~ /http:/ or file_path =~ /https:/ or file_path =~ /ftp:/
      name = screenshot_name(File.basename(options[:file_path]), options[:line_number])

      "#{file_path}/#{name}"
    else
      name = screenshot_name(File.basename(options[:file_path]), options[:line_number])

      path = File.expand_path("#{basedir}/#{name}")

      "file:///#{path}"
    end
  end

end
