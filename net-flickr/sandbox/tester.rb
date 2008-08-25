#!/opt/local/bin/ruby
short_dir = File.join(File.dirname(__FILE__), '../lib')
long_dir = File.join(File.expand_path(File.dirname(__FILE__)), '../lib')
unless $:.include?(short_dir) || $:.include?(long_dir)
  $:.unshift(short_dir) 
end

require 'net/flickr'

# FLICKR_KEY  = '3918b75b450370617b0cfe084298a78f'
# FLICKR_SECRET   = 'cdae791445fe86ff'
FLICKR_FROB     = '72157602339325438-05a7a6ae19fc87ab-128703'
FLICKR_TOKEN    = '262947-a5aabd1c1491ae38'
FLICKR_WILDFLOWER_ID = '84089850@N00'

N8_ID = '45285223@N00'
MIN_ID = '7232133@N08'

N8_PHOTO = 2385693150
TENGU_PHOTO = 2370803043

FLICKR_KEY = '5b1baa592d079b7a59ff4d8989b17c1a'
FLICKR_SECRET = 'e49b207797eb11f1'

# class LibXML::XML::Node
#   def method_missing(method)
#     elem = self.find_first(method.to_s)
#     elem unless elem.nil?
#   end
# end

@f = Net::Flickr.new(FLICKR_KEY, FLICKR_SECRET)

# @t = @f.test.echo({'ftwo' => 'kiwi',
#                  'foo'  => 'bar',
#                  'one'  => 'two'})

@photos = @f.photos.search('user_id' => N8_ID, 'text' => 'nudibranch')
# p photos.size
# p photos[0].title
# p photos[0].description
# p photos[0].to_json
# p ""
# p Net::Flickr.last_response