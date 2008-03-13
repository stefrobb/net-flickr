short_dir = File.join(File.dirname(__FILE__), '../lib/net')
long_dir = File.join(File.expand_path(File.dirname(__FILE__)), '../lib/net')
unless $:.include?(short_dir) || $:.include?(long_dir)
  $:.unshift(short_dir) 
end

# require the helpers
require File.join(File.dirname(__FILE__), "spec_helpers", "flickr_generator")

require 'flickr'

FLICKR_API_KEY = '3918b75b450370617b0cfe084298a78f'
FLICKR_API_SECRET = 'cdae791445fe86ff'