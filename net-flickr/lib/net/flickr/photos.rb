#--
# Copyright (c) 2007 Ryan Grove <ryan@wonko.com>
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

module Net; class Flickr

  # Provides methods for retrieving and/or manipulating one or more Flickr
  # photos.
  # 
  # Do not instantiate this class yourself. Instead, create an instance of the
  # Flickr class and then use <tt>Flickr.photos</tt> to access this class, like
  # so:
  # 
  #   require 'net/flickr'
  #   
  #   flickr = Net::Flickr.new('524266cbd9d3c2xa2679fee8b337fip2')
  #   
  #   flickr.photos.recent.each do |photo|
  #     puts photo.title
  #   end
  #
  class Photos
  
    def initialize(flickr)
      @flickr = flickr
    end

    # Gets a list of recent photos from the calling user's contacts. This method
    # requires authentication with +read+ permission.
    # 
    # See http://flickr.com/services/api/flickr.photos.getContactsPhotos.html
    # for details.
    def contacts(args = {})
      response = @flickr.request('flickr.photos.getContactsPhotos', args)
      
      photos = []
      
      response.search('photos/photo').each do |photo_xml|
        photos << Photo.new(@flickr, photo_xml)
      end
      
      return photos
    end
    
    # Gets a list of recent public photos from the specified user's contacts.
    # 
    # See http://flickr.com/services/api/flickr.photos.getContactsPublicPhotos.html
    # for details.
    def contacts_public(user_id, args = {})
      args['user_id'] = user_id
      
      response = @flickr.request('flickr.photos.getContactsPublicPhotos', args)
      
      photos = []
      
      response.search('photos/photo').each do |photo_xml|
        photos << Photo.new(@flickr, photo_xml)
      end
      
      return photos
    end
    
    # Gets a list of photo counts for the given date ranges for the calling
    # user. The list of photo counts is returned as an XML chunk. This method
    # requires authentication with +read+ permission.
    # 
    # See http://flickr.com/services/api/flickr.photos.getCounts.html for
    # details.
    def counts(args = {})
      return @flickr.request('flickr.photos.getCounts', args).at('photocounts').
          to_original_html
    end
    
    # Deletes the specified photo from Flickr. This method requires
    # authentication with +delete+ permission.
    # 
    # See http://flickr.com/services/api/flickr.photos.delete.html for details.
    def delete(photo_id)
      @flickr.request('flickr.photos.delete', 'photo_id' => photo_id)
      return true
    end
    
    # Gets a list of the calling user's geotagged photos. This method requires
    # authentication with +read+ permission.
    # 
    # See http://flickr.com/services/api/flickr.photos.getWithGeoData.html for
    # details.
    def geotagged(args = {})
      return PhotoList.new(@flickr, 'flickr.photos.getWithGeoData', args)
    end
    
    # Gets a list of the calling user's photos that have not been geotagged.
    # This method requires authentication with +read+ permission.
    # 
    # See http://flickr.com/services/api/flickr.photos.getWithoutGeoData.html
    # for details.
    def not_geotagged(args = {})
      return PhotoList.new(@flickr, 'flickr.photos.getWithoutGeoData', args)
    end

    # Gets a list of the calling user's photos that are not included in any
    # sets. This method requires authentication with +read+ permission.
    # 
    # See http://flickr.com/services/api/flickr.photos.getNotInSet.html for
    # details.
    def not_in_set(args = {})
      return PhotoList.new(@flickr, 'flickr.photos.getNotInSet', args)
    end
    
    # Gets a list of the latest public photos uploaded to Flickr.
    # 
    # See http://flickr.com/services/api/flickr.photos.getRecent.html for
    # details.
    def recent(args = {})
      return PhotoList.new(@flickr, 'flickr.photos.getRecent', args)
    end
    
    # Gets a list of the calling user's photos that have been created or
    # modified since the specified _min_date_. This method requires
    # authentication with +read+ permission.
    # 
    # _min_date_ may be either an instance of Time or an integer representing a
    # Unix timestamp.
    # 
    # See http://flickr.com/services/api/flickr.photos.recentlyUpdated.html for
    # details.
    def recently_updated(min_date, args = {})
      args['min_date'] = min_date.to_i
      return PhotoList.new(@flickr, 'flickr.photos.recentlyUpdated', args)
    end
    
    # Gets a list of photos matching the specified criteria. Only photos visible
    # to the calling user will be returned. To return private or semi-private
    # photos, the caller must be authenticated with +read+ permission and have
    # permission to view the photos. Unauthenticated calls will return only
    # public photos.
    # 
    # See http://flickr.com/services/api/flickr.photos.search.html for details.
    # 
    # Note: Flickr doesn't allow parameterless searches, so be sure to specify
    # at least one search parameter.
    def search(args = {})
      return PhotoList.new(@flickr, 'flickr.photos.search', args)
    end
    
    # Gets a list of the calling user's photos that have no tags. This method
    # requires authentication with +read+ permission.
    # 
    # See http://flickr.com/services/api/flickr.photos.getUntagged.html for
    # details.
    def untagged(args = {})
      return PhotoList.new(@flickr, 'flickr.photos.getUntagged', args)
    end
    
  end

end; end
