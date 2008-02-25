module FlickrGeneratorHelper
  def unsigned_flickr(api_key = FLICKR_API_KEY)
    return Net::Flickr.new(api_key)
  end
  
  def signed_flickr(api_key = FLICKR_API_KEY, secret = FLICKR_SECRET)
    return Net::Flickr.new(api_key, secret)
  end 
end