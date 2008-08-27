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

    # A Flickr photo.
    class Photo
      
      SIZE_SUFFIX = {
        :square   => 's',
        :thumb    => 't',
        :small    => 'm',
        :medium   => nil,
        :large    => 'b',
        :original => 'o'
      }

      def initialize(photo)
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
      
      def method_missing(method, args={})
        get_info
        var = "@" + method.to_s
        if instance_variable_defined?(var)
          return instance_variable_get(var)
        end
      end
      
      ###
      # Getters
      ###
      
      # id has to be set explicitly to override Ruby's native id method
      def id
        @id
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
      
      # Whether or not this photo is visible to family.
      def is_family?
        get_info
        @isfamily
      end
      
      def is_favorite?
        get_info
        @isfavorite
      end

      # Whether or not this photo is visible to friends.
      def is_friend?
        get_info
        @isfriend
      end
      
      # Whether or not this photo is visible to the general public.
      def is_public?
        get_info
        @ispublic
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
        response = Net::Flickr.request('flickr.photos.getInfo',
                                       {:photo_id => @id, 
                                        :secret   => @secret})
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
          @id        = xml[:id]
          @owner     = xml[:owner]
          @secret    = xml[:secret]
          @server    = xml[:server]
          @farm      = xml[:farm]
          @title     = xml[:title]
          @ispublic  = xml[:ispublic] == '1'
          @isfriend  = xml[:isfriend] == '1'
          @isfamily  = xml[:isfamily] == '1'
        
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
          @isfavorite     = xml[:isfavorite]
          @license        = xml[:license]
          @rotation       = xml[:rotation]
          @originalsecret = xml[:originalsecret]
          @originalformat = xml[:originalformat]

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
            @isfamily = visibility[:isfamily] == '1'
            @isfriend = visibility[:isfriend] == '1'
            @ispublic = visibility[:ispublic] == '1'
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
            @cancomment = editability[:cancomment] == '1'
            @canaddmeta = editability[:canaddmeta] == '1'
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
