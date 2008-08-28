#!/opt/local/bin/ruby
short_dir = File.join(File.dirname(__FILE__), '../lib')
long_dir = File.join(File.expand_path(File.dirname(__FILE__)), '../lib')
unless $:.include?(short_dir) || $:.include?(long_dir)
  $:.unshift(short_dir) 
end

require 'net/flickr'

FLICKR_FROB     = '72157602339325438-05a7a6ae19fc87ab-128703'
FLICKR_TOKEN    = '262947-a5aabd1c1491ae38'
FLICKR_WILDFLOWER_ID = '84089850@N00'

N8_ID = '45285223@N00'
MIN_ID = '7232133@N08'

N8_PHOTO = 2385693150
TENGU_PHOTO = 2370803043

FLICKR_KEY = '5b1baa592d079b7a59ff4d8989b17c1a'
FLICKR_SECRET = 'e49b207797eb11f1'

@f = Net::Flickr.new(FLICKR_KEY, FLICKR_SECRET)

# Hit the test endpoint
# test = @f.test.echo({:foo => 'bar'})
# p test.keys

# Photos tests
# @photos = @f.photos.search('user_id' => N8_ID, 'text' => 'nudibranch')
# 
# p @photos.length
# p @photos[0].title
# p @photos[0].description

# photo test
@photo = @f.photos.get_info(N8_PHOTO)
# p @photo.title