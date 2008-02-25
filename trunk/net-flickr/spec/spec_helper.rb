short_dir = File.join(File.dirname(__FILE__), '../lib/net')
long_dir = File.join(File.expand_path(File.dirname(__FILE__)), '../lib/net')
unless $:.include?(short_dir) || $:.include?(long_dir)
  $:.unshift(short_dir) 
end

# require the helpers
require File.join(File.dirname(__FILE__), "spec_helpers", "flickr_generator")

require 'flickr'

FLICKR_API_KEY  = ''
FLICKR_SECRET   = ''

FLICKR_WILDFLOWER_ID = '84089850@N00'