require 'gherkin/lexer/i18n_lexer'

class GherkinExt

  def self.enable_external_source data_reader
    lexer = Gherkin::Lexer::I18nLexer

    lexer.class_eval do
      @data_reader = data_reader # class instance variable

      def self.data_reader # access to class instance variable
        @data_reader
      end

      alias_method :old_scan, :scan

      def scan(source)
        old_scan self.class.modify_source(source)
      rescue
        pust "Error in #{source} file."
      end

      private

      def self.modify_source source
        if source =~ /file\s?:/
          new_source = ""

          source.each_line do |line|
            if line =~ /file\s?:/
              part1, part2 = line.split(",")

              source_path = part1.gsub('file:', '').gsub('|', '').strip
              key = part2 ? part2.gsub('key:', '').gsub('|', '').strip : nil

              if source_path
                values = self.data_reader.call(source_path)

                data = key.nil? ? values : values[key]

                new_source += build_data_section data
              end
            else
              new_source += line
            end

            new_source += "\n"
          end

          new_source
        else
          source
        end
      end

      def self.build_data_section values
        buffer = ""

        values.each do |row|
          buffer += "  |"

          row.each do |element|
            buffer += " #{element} |"
          end

          buffer += "\n"
        end

        buffer
      end
    end
  end

end
