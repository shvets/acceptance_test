require 'singleton'

require 'gherkin/lexer/i18n_lexer'

class GherkinHelper
  include Singleton

  def enable_external_source data_reader
    lexer = Gherkin::Lexer::I18nLexer

    lexer.class_eval do
      @data_reader = data_reader # class instance variable

      def self.data_reader # access to class instance variable
        @data_reader
      end

      alias_method :old_scan, :scan

      def scan(source)
        old_scan self.class.modify_source(source)
      end

      private

      def self.modify_source source
        if source =~ /file\s?:/
          new_source = ""

          source.each_line do |line|
            if line =~ /file\s?:/
              source_path = line.gsub('file:', '').gsub('|', '').strip

              if source_path
                values = self.data_reader.call(source_path)

                values.each do |row|
                  new_source += "  |"

                  row.each do |element|
                    new_source += " #{element} |"
                  end
                  new_source += "\n"
                end
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
    end
  end

end
