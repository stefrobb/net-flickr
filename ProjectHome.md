# Update 1/30/09 #

Ryan and I are not heavily maintaining net-flickr any longer.  Personally, I have tinkered with many updates to net-flickr only to find out that many others have proceeded me with those same ideas in an ever growing pool of other Ruby based Flickr API wrappers.  The hardest problem of maintaining this wrapper is authoring custom interfaces for every API method Flickr releases, and then wrapping those custom methods into a proprietary network of Ruby object relationships.  This simply doesn't scale out.  Instead others have realized a better potential interface: using Flickr's own API introspection methods.  I'm currently looking at the flickraw project as a way to move forward with Flickr API interaction in Ruby.  flickraw simply builds its list of methods at runtime and provides an interface to accessing every native endpoint (all in less than 300 lines of Ruby, it's quite brilliant).  If you're interested in taking over net-flickr just let me know.

Flickraw:
http://github.com/hanklords/flickraw/tree/master

# Overview #

Net::Flickr is an elegant, Ruby-fied implementation of Flickr's REST API.

# Requirements #

  * [Ruby](http://www.ruby-lang.org/) 1.8.5+
  * [Hpricot](http://code.whytheluckystiff.net/hpricot/) 0.5+

# Basic Usage #

```
#!/usr/bin/env ruby
require 'rubygems'
require 'net/flickr'

flickr = Net::Flickr.authorize('524266cbd9d3c2xa2679fee8b337fip2')

# Print the titles of the 100 newest Flickr photos.
flickr.photos.recent.each {|photo| puts photo.title }

# Print the titles of the last 10 photos uploaded by user wonko.
flickr.people.find_by_username('wonko').photos('per_page' => 10).each do |photo|
  puts photo.title
end

# Print the titles of the 10 most recent public photos tagged with either
# 'monkey' or 'ninja'.
flickr.photos.search('tags' => 'monkey,ninja', 'per_page' => 10).each do |photo|
  puts photo.title
end
```