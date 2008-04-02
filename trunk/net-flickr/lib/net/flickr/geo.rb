module Net; class Flickr; class Photo

  # A Flickr photo tag.
  # 
  # Don't instantiate this class yourself.
  class Geo
  
    #attr_reader :id, :author, :raw, :name
    
    def initialize(photo)
      @photo = photo
      
      #@id          = geo_xml['id']
      # @author      = tag_xml['author']
      # @raw         = tag_xml['raw']
      # @name        = tag_xml.inner_text
      # @machine_tag = tax_xml['machine_tag'] == '1'
    end
    
    def get_location
      response = Net::Flickr.instance().request('flickr.photos.geo.getLocation',
                                                'photo_id' => @photo.id)
      return {'lat' => response.at('location')['latitude'],
              'lng' => response.at('location')['longitude']}
      
      rescue Net::Flickr::APIError
        return nil
    end
    
    alias :location :get_location
    
    def set_location(args = {})
    end
    
    alias :location= :set_location
  
  end

end; end; end
