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

  # A Flickr photo.
  # 
  # Don't instantiate this class yourself. Use the methods in
  # Flickr::Photos to retrieve photos from Flickr.
  class Photo
    SIZE_SUFFIX = {
      :square   => 's',
      :thumb    => 't',
      :small    => 'm',
      :medium   => nil,
      :large    => 'b',
      :original => 'o'
    }
  
    attr_reader :id, :owner, :secret, :server, :farm, :title
    
    def initialize(flickr, xml)
      @flickr = flickr
      
      unless xml.is_a?(Hpricot::Elem)
        raise ArgumentError, "Invalid argument: xml"
      end
      
      @id        = xml['id']
      @owner     = xml['owner']
      @secret    = xml['secret']
      @server    = xml['server']
      @farm      = xml['farm']
      @title     = xml['title']
      @is_public = xml['ispublic'] == '1'
      @is_friend = xml['isfriend'] == '1'
      @is_family = xml['isfamily'] == '1'
      
      # Detailed photo info.
      @infoxml = nil
    end
    
    #--
    # Public Instance Methods
    #++
    
    # Deletes this photo from Flickr. This method requires authentication with
    # +delete+ permission.
    def delete
      @flickr.photos.delete(@id)
    end
    
    # Gets this photo's description.
    def description
      infoxml = get_info
      return infoxml.at('description').inner_text
    end
    
    # Sets this photo's description. This method requires authentication with
    # +write+ permission.
    def description=(value)
      set_meta(@title, value)
      return value
    end
    
    # flickr.photos.getExif
    def exif
    end
    
    # Whether or not this photo is visible to family.
    def family?
      return @is_family || @is_public
    end

    # flickr.photos.getFavorites
    def favorites
    end
    
    # Whether or not this photo is visible to friends.
    def friend?
      return @is_friend || @is_public
    end
    
    # flickr.photos.getExif
    def gps
    end
    
    # Gets the time this photo was last modified.
    def modified
      infoxml = get_info
      return Time.at(infoxml.at('dates')['lastupdate'].to_i)
    end
    
    # flickr.photos.getContext
    def next
    end
    
    # Gets the URL of this photo's Flickr photo page.
    def page_url
      return "http://www.flickr.com/photos/#{@owner}/#{@id}"
    end
    
    # flickr.photos.getAllContexts
    def pools
    end
    
    # Gets the time this photo was posted to Flickr.
    def posted
      infoxml = get_info
      return Time.at(infoxml.at('dates')['posted'].to_i)
    end
    
    # flickr.photos.setDates
    def posted=(time)
    end
    
    # flickr.photos.getContext
    def previous
    end

    alias prev previous
    
    # Whether or not this photo is visible to the general public.
    def public?
      return @is_public
    end
    
    # flickr.photos.getAllContexts
    def sets
    end
    
    # flickr.photos.getSizes
    def sizes
    end
    
    # Gets the source URL for this photo at one of the following specified
    # sizes.
    # 
    # [:square]   75x75px
    # [:thumb]    100px on longest side
    # [:small]    240px on longest side
    # [:medium]   500px on longest side
    # [:large]    1024px on longest side (not available for all images)
    # [:original] original image in original file format
    def source_url(size = :medium)
      suffix = SIZE_SUFFIX[size]
      
      case size
        when :medium
          url = "http://farm#{@farm}.static.flickr.com/#{@server}/#{@id}_#{@secret}.jpg"
        
        when :original
          # TODO: Support original source URLs
          url = 'not yet supported'
        
        else
          url = "http://farm#{@farm}.static.flickr.com/#{@server}/#{@id}_#{@secret}_#{suffix}.jpg"
      end
      
      return url
    end
    
    # flickr.photos.getInfo
    def tags
    end
    
    # Gets the time this photo was taken.
    def taken
      infoxml = get_info
      return Time.parse(infoxml.at('dates')['taken'])
    end
    
    # flickr.photos.setDates
    def taken=(time)
    end
    
    # flickr.photos.getExif
    def tiff
    end
    
    # Sets this photo's title. This method requires authentication with +write+
    # permission.
    def title=(value)
      set_meta(value, description)
      return true
    end
    
    #--
    # Private Instance Methods
    #++
    
    private
    
    # Gets detailed information for this photo.
    def get_info
      return @infoxml unless @infoxml.nil?

      response = @flickr.request('flickr.photos.getInfo', 'photo_id' => @id, 
          'secret' => @secret)
      
      return @infoxml = response.at('photo')
    end
    
    # Sets date information for this photo.
    def set_dates(posted, taken, granularity = 0, args = {})
    end
    
    # Sets meta information for this photo.
    def set_meta(title, description, args = {})
      args['photo_id']    = @id
      args['title']       = title
      args['description'] = description
      
      @flickr.request('flickr.photos.setMeta', args)
      
      @infoxml = nil
    end
  
  end

end; end
