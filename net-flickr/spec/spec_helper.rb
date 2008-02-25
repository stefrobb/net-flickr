short_dir = File.join(File.dirname(__FILE__), '../lib/net')
long_dir = File.join(File.expand_path(File.dirname(__FILE__)), '../lib/net')
unless $:.include?(short_dir) || $:.include?(long_dir)
  $:.unshift(short_dir) 
end

# require the helpers
require File.join(File.dirname(__FILE__), "spec_helpers", "flickr_generator")

require 'flickr'

FLICKR_API_KEY  = '3918b75b450370617b0cfe084298a78f'
FLICKR_SECRET   = 'cdae791445fe86ff'

FLICKR_FROB     = '72157602339325438-05a7a6ae19fc87ab-128703'
FLICKR_TOKEN    = '262947-a5aabd1c1491ae38'

FLICKR_WILDFLOWER_ID = '84089850@N00'