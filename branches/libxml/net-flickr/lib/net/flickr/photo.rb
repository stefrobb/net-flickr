# Copyright (c) 2007-2008 Ryan Grove <ryan@wonko.com>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
# * Neither the name of this project nor the names of its contributors may be
#   used to endorse or promote products derived from this software without
#   specific prior written permission.
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

# The following are not covered in the attributes because they require
# more extensive scripting:
# owner
# comments
# notes
# tags
# urls

module Net
  class Flickr
    class Photo
      
      def self.attrs_req_get_info(*args)
        args.each do |attribute|
          define_method(attribute) do
            get_info
            instance_variable_get("@#{attribute}")
          end
        end
      end
      
      def self.attrs_req_get_info?(*args)
        args.each do |attribute|
          define_method("#{attribute}?") do
            get_info
            instance_variable_get("@#{attribute}")
          end
        end
      end
      
      attr_reader :id
      attrs_req_get_info :secret, :server, :farm, :license, :rotation, :originalsecret,
                         :originalformat, :title, :description, :comment_count, :tags,
                         :longitude, :latitude, :accuracy
                         
      attrs_req_get_info? :is_family, :is_favorite, :is_public, :is_friend
      
      SIZE_SUFFIX = {
        :square   => 's',
        :thumb    => 't',
        :small    => 'm',
        :medium   => nil,
        :large    => 'b',
        :original => 'o'
      }

      def initialize(photo)
        raise AuthorizationError, 'Net::Flickr::Photo requires a Net::Flickr::Connection object to connect to the flickr API' if Net::Flickr.connection.nil?
        
        @xml = nil
        @context_xml = nil
        
        if photo.class == LibXML::XML::Node
          parse(photo)
        elsif photo.to_i != 0
          @id = photo
        else
          raise "Cannot initialize Net::Flickr::Photo.new because the 'photo' paramter was a: #{photo.class}."
        end
      end
      
      ###
      # Setters
      ###
      
      def title=(val)
        set_meta(val, @description)
      end

      # Sets this photo's description. This method requires authentication with
      # +write+ permission.
      def description=(val)
        set_meta(@title, val)
      end

      ###
      # Conditionals
      ###

      # Check to see if there are comments for the photo
      def has_comments?
        get_info
        @comment_count > 0
      end

      ###
      # Actions
      ###
      
      # Deletes this photo from Flickr. This method requires authentication with
      # +delete+ permission.
      def delete
        Net::Flickr.request('flickr.photos.delete', {'id' => @id})
      end
      
      # Gets context information for this photo.
      def get_context
        @context_xml ||= Net::Flickr.request('flickr.photos.getContext', {'photo_id' => @id})
      end

      # Gets the next photo in the owner's photo stream, or +nil+ if this is the
      # last photo in the stream.
      def next
        next_photo = get_context.find_first('nextphoto')
        return nil if next_photo[:id] == '0'
        Photo.new(next_photo)
      end    
          
      # Gets the previous photo in the owner's photo stream, or +nil+ if this is
      # the first photo in the stream.
      def previous
        previous_photo = get_context.find_first('prevphoto')
        return nil if previous_photo[:id] == '0'
        Photo.new(previous_photo)
      end
      
      # Gets the URL of this photo's Flickr photo page.
      def page_url
        get_info
        "http://www.flickr.com/photos/#{@owner[:username]}/#{@id}"
      end
      
      # Gets the source URL for this photo at one of the following specified
      # sizes. Returns +nil+ if the specified _size_ is not available.
      # 
      # [:square]   75x75px
      # [:thumb]    100px on longest side
      # [:small]    240px on longest side
      # [:medium]   500px on longest side
      # [:large]    1024px on longest side (not available for all images)
      # [:original] original image in original file format
      def source_url(size = :medium)
        get_info
        suffix = SIZE_SUFFIX[size]
        case size
          when :medium
            return "http://farm#{@farm}.static.flickr.com/#{@server}/#{@id}_#{@secret}.jpg"
        
          when :original
            get_info
          
            return nil if @originalsecret.nil? || @originalformat.nil? 
            return "http://farm#{@farm}.static.flickr.com/#{@server}/#{@id}_#{@originalsecret}_o.#{@originalformat}"
      
          else
            return "http://farm#{@farm}.static.flickr.com/#{@server}/#{@id}_#{@secret}_#{suffix}.jpg"
        end
      end

      # Gets detailed information for this photo.
      def get_info(force=false)
        return unless (@xml.nil? || force)
        response = Net::Flickr.request('flickr.photos.getInfo', {:photo_id => @id, :secret => @secret})
        @xml = response.find_first('photo')
        parse(@xml)
      end
      
      def reload
        get_info(true)
      end
    
      private
      # Parse a photo xml chunk.
      def parse(xml)
        # Photo info comes in three formats
        if xml[:owner] && xml[:ispublic]
          @id         = xml[:id]
          @owner      = xml[:owner]
          @secret     = xml[:secret]
          @server     = xml[:server]
          @farm       = xml[:farm]
          @title      = xml[:title]
          @is_public  = xml[:ispublic] == '1'
          @is_friend  = xml[:isfriend] == '1'
          @is_family  = xml[:isfamily] == '1'
        
        # This is a context XML chunk. It doesn't include visibility info.
        elsif xml[:url] && xml[:thumb]
          @id        = xml[:id]
          @secret    = xml[:secret]
          @server    = xml[:server]
          @farm      = xml[:farm]
          @title     = xml[:title]
          
        # This is a detailed XML chunk (probably from flickr.photos.getInfo).      
        elsif xml[:secret] && xml.find_first('owner')
          @xml = xml
          
          @id             = xml[:id]
          @secret         = xml[:secret]
          @server         = xml[:server]
          @farm           = xml[:farm]
          @secret         = xml[:secret]
          @server         = xml[:server]
          @license        = xml[:license]
          @rotation       = xml[:rotation]
          @originalsecret = xml[:originalsecret]
          @originalformat = xml[:originalformat]
          @is_favorite    = xml[:isfavorite] == '1'

          # major attributes
          @title = xml.find_first('title').content.to_s
          @description = xml.find_first('description').content.to_s
          @comment_count = xml.find_first('comments').content.to_i
          
          @owner = {}
          owner = xml.find_first('owner')
          if owner
            @owner[:nsid] = owner[:nsid]
            @owner[:username] = owner[:username]
            @owner[:realname] = owner[:realname]
            @owner[:location] = owner[:location]
          end

          # visibility
          visibility = xml.find_first('visibility')
          if visibility
            @is_family = visibility[:isfamily] == '1'
            @is_friend = visibility[:isfriend] == '1'
            @is_public = visibility[:ispublic] == '1'
          end

          # dates
          dates = xml.find_first('dates')
          if dates
            @posted = Time.at(dates[:posted].to_i) if !dates[:posted].nil?
            @taken  = Time.at(dates[:taken].to_i) if !dates[:taken].nil?
            @takengranularity = dates[:takengranularity]
            @lastupdate = Time.at(dates[:lastupdate].to_i) if !dates[:lastupdate].nil?
          end

          # permissions
          permissions = xml.find_first('permissions')
          if permissions
            @permcomment = permissions[:permcomment]
            @permaddmeta = permissions[:permaddmeta]
          end

          # editability
          editability = xml.find_first('editability')
          if editability
            @can_comment = editability[:cancomment] == '1'
            @can_add_meta = editability[:canaddmeta] == '1'
          end
          
          @tags = {}
          tags = xml.find('tags/tag')
          if tags.size > 0
            tags.each {|tag| @tags[tag.content] = Net::Flickr::Tag.new(tag)}
          end
          tags = nil # REQUIRED! SEE: http://libxml.rubyforge.org/rdoc/classes/LibXML/XML/Document.html#M000354
          
          location = xml.find_first('location')
          if location
            @longitude = location[:longitude].to_f
            @latitude  = location[:latitude].to_f
            @accuracy  = location[:accuracy].to_f
          end
        end
        
        # Sets meta information for this photo.
        def set_meta(title, description, args={})
          args[:photo_id]    = @id
          args[:title]       = title
          args[:description] = description
          Net::Flickr.request('flickr.photos.setMeta', args)
          @xml = nil
        end
        
      end
    end
  end
end
