class ScreenshotMaker
  attr_accessor :basedir

  def initialize basedir
    @basedir = basedir
  end

  def make page, options
    file_path = options[:file_path]

    name = screenshot_name(build_name(file_path), options[:line_number])
    path = File.expand_path("#{basedir}/#{name}")

    page.save_screenshot(path)
  end

  def screenshot_url options
    file_path = options[:file_path]

    if options[:screenshot_url_base]
      name = screenshot_name(build_name(file_path), options[:line_number])

      "#{options[:screenshot_url_base]}/#{name}"
    else
      name = screenshot_name(build_name(file_path), options[:line_number])

      path = File.expand_path("#{basedir}/#{name}")

      "file:///#{path}"
    end
  end

  private

  def screenshot_name name, line_number=nil
    "#{name}#{line_number ? '-'+line_number.to_s : ''}.png"
  end

  def build_name path
    full_path = File.expand_path(path)

    spec_index = full_path.index("/spec")

    if spec_index
      extension = File.extname(path)
      ext_index = extension.size == 0 ? -1 : full_path.index(extension)-1

      name = full_path[spec_index+1..ext_index].gsub("/", "_")

      name = name[5..-1] if name =~ /^spec_/
      name = name[9..-1] if name =~ /^features_/
      name = name[11..-1] if name =~ /^acceptance_/
    else
      name = path
    end

    name
  end

end
