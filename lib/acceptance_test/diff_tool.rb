require 'singleton'

class DiffTool
  include Singleton

  def diff source, target
    phrases1 = []

    keywords_exp1 = /^(Given|When|Then|And|But)/

    File.open(source).each_line do |line|
      line = line.strip

      if line !~ /^#/ and line =~ keywords_exp1
        word = line.scan(keywords_exp1)[0][0]

        phrases1 << line[word.size..-1].strip
      end
    end

    phrases2 = []

    keywords_exp2 = /step\s+('|")(.*)('|")/

    File.open(target).each_line do |line|
      line = line.strip

      if line !~ /^#/ and line =~ keywords_exp2
        phrases2 << line.scan(keywords_exp2)[0][1]
      end
    end

    ok = true

    phrases1.each_with_index do |phrase, index|
      phrase1 = phrase.clone.gsub("\"", "'")
      phrase2 = phrases2[index]

      if phrase1.nil? or phrase2.nil?
        puts "Different amount of steps:"
        puts "  source: #{phrases1.size}"
        puts "  target: #{phrases2.size}"
        ok = false
        break
      end

      params = phrase2.gsub(/:\w+\S/).to_a

      params.each do |param|
        new_param = param.gsub(":", "")

        phrase1.gsub!(%r{<#{new_param}>}, param)
      end

      params.each do |param|
        phrase1.gsub!(/'(\w|\s)*'/, param)
      end

      params.each do |param|
        phrase1.gsub!(/'(.)*'/, param)
      end

      if phrase1 != phrase2
        puts "Fail:"
        puts "  #{phrase}"
        puts "  #{phrases2[index]}"
        ok = false
      else
        puts "OK:"
        puts "  #{phrase}"
        puts "  #{phrases2[index]}"
      end
    end

    if ok
      puts "Everything is OK."
    else
      puts "Some errors exist!"
    end
  end
end
