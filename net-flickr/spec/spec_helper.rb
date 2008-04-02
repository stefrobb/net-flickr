$:.unshift(File.join(File.dirname(__FILE__), '../lib/net'))
$:.uniq!

# require the helpers
require File.join(File.dirname(__FILE__), "spec_helpers", "flickr_generator")
require 'flickr'

FLICKR_KEY      = '3918b75b450370617b0cfe084298a78f'
FLICKR_SECRET   = 'cdae791445fe86ff'
FLICKR_PHOTO_ID = '69861682'