require 'parallel'
require 'nokogiri'
require 'open-uri'
require 'kramdown'

BASE_URI = ENV['BASE_URI'] || 'https://github.com/jondot/awesome-react-native'

doc = Nokogiri::HTML(Kramdown::Document.new(open('README.md').read).to_html)
links = doc.css('a').to_a
puts "Validating #{links.count} links..."

invalids = []
Parallel.each(links, :in_threads => 4) do |link|
  begin
    uri = URI.join(BASE_URI, link.attr('href'))
    open(uri)
    putc('.')
  rescue
    putc('F')
    invalids << link
  end
end

unless invalids.empty?
  puts "\n\nFailed links:"
  invalids.each do |link|
    puts "- #{link.text}"
  end
  puts "Done with errors."
  exit(1)
end

puts "\nDone."
