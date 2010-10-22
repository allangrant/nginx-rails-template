def template(file)
  load_template "#{@template_path}/#{file}.rb"
end

def ask_with_default(question, default)
  input = ask("#{question} [#{default}]:")
  input.blank? ? default : input
end

def comment(text)
  puts "              >> #{text}"
end

def ask_boolean(question, default, options=nil)
  options[:default] ||= default ? "Yes" : "No"
  input = ask("#{question} [#{options[:default]}]:")
  if input.blank?
    result = default
  else
    case input.downcase
    when options[:default].downcase
      result = default
    when /^(y|t|yes|true)$/:
      result =  true
    when /^(n|f|no|false)$/:
      result =  false
    else
      raise "Not a valid option. Enter Yes or No."
    end
  end
  comment options[:if_true] if options[:if_true] && result
  comment options[:if_false] if options[:if_false] && !result
  return result
end

