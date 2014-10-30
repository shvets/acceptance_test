require 'singleton'

class StepsGenerator
  include Singleton

  def generate file_name
    keywords_exp = /^(Given|When|Then|And|But)/

    File.open(file_name).each_line do |line|
      line = line.strip

      if line !~ /^#/ and line =~ keywords_exp
        title = line.gsub(keywords_exp, "").strip

        params = line.gsub(/('<\w+>')|("<\w+>")|(<\w+>)|(".+")|('.+')/).to_a
        new_params = []

        params.each_with_index do |param, index|
          key = param.gsub(/(<|>|'|")/, "").downcase

          if key =~ /\s+/
            key = key.underscore.gsub(/\s+/, "_")
          end

          value = param.gsub(/('|")/, "")

          new_params[index] = [key, value]
          title.gsub!(param, ":#{key}")
        end

        new_params.each do |key, value|
          print "\n"
          print "input[:#{key}] = \"#{value}\""
          print "\n"
        end

        print "\n"
        print "step '#{title}' do "

        if new_params.size > 0
          print "|"

          new_params.each_with_index do |array, index|
            print "#{array.first}"
            print ", " if index < params.size-1
          end

          print "|"
        end

        print "\n\n"
        print "end\n"
      end
    end
  end
end