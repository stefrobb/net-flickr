#--
# Copyright (c) 2007-2008 Ryan Grove <ryan@wonko.com>
# Copyright (c) 2008 Nate Agrin <n8@n8agrin.com>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#   * Redistributions of source code must retain the above copyright notice,
#     this list of conditions and the following disclaimer.
#   * Redistributions in binary form must reproduce the above copyright notice,
#     this list of conditions and the following disclaimer in the documentation
#     and/or other materials provided with the distribution.
#   * Neither the name of this project nor the names of its contributors may be
#     used to endorse or promote products derived from this software without
#     specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#++

# Append this file's directory to the include path if it's not there already.
$:.unshift(File.dirname(__FILE__))
$:.uniq!

# stdlib includes
require 'digest/md5'
require 'net/http'
require 'uri'
require 'rubygems'
require 'libxml'

# Include teh support
require 'flickr/support/connection'
# require 'flickr/support/xml_magic_libxml'
require 'flickr/support/libxml_hpricot'

# Net::Flickr's glorious errors
require 'flickr/errors'

# Flickr endpoint classes
require 'flickr/base'
require 'flickr/test'

# Net::Flickr includes
require 'flickr/auth'
# require 'flickr/contacts'
# require 'flickr/geo'
# require 'flickr/people'
# require 'flickr/person'
require 'flickr/photo'
require 'flickr/photos'
# require 'flickr/tag'

# Net::Flickr List classes
require 'flickr/list'
# require 'flickr/contactlist'
require 'flickr/photolist'

# = Net::Flickr
# 
# This library implements Flickr's REST API. Its usage should be pretty
# straightforward. See below for examples.
# 
# Author::    Ryan Grove (mailto:ryan@wonko.com)
# Author::    Nate Agrin (mailto:n8@n8agrin.com) 
# Version::   0.5
# Copyright:: Copyright (c) 2007-2008 Ryan Grove. All rights reserved.
# Copyright:: Copyright (c) 2008 Nate Agrin. All rights reserved.
# License::   New BSD License (http://opensource.org/licenses/bsd-license.php)
# Website::   http://code.google.com/p/net-flickr/
#
module Net
  class Flickr
        
    class << self
      attr_reader :connection

      def connection=(thing)
        unless thing.kind_of?(Net::Flickr::Connection)
          raise 'A connection must be a kind of Net::Flickr::Connection'
        end
        @connection = thing
      end
      
      def request(method, args={})
        @connection.request(method, args)
      end
    end
    
    VERSION = '0.5'.freeze

    def initialize(key, secret=nil, token=nil)
      Net::Flickr.connection = Net::Flickr::Connection.new(key, secret, token)
    end
    
    # calls to the inner classes
    def auth
      @auth ||= Net::Flickr::Auth
    end

    def contacts
      @contacts ||= Net::Flickr::Contacts
    end

    def people
      @people ||= Net::Flickr::People
    end

    def photos
      @photos ||= Net::Flickr::Photos
    end

    def photosets
      @photosets ||= Net::Flickr::Photosets
    end

    def test
      @test ||= Net::Flickr::Test
    end

  end # Net::Flickr
end # Net