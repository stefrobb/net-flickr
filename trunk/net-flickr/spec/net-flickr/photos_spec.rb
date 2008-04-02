require (File.join(File.dirname(__FILE__), '../spec_helper.rb'))

describe Net::Flickr::Photos do
  include FlickrGeneratorHelper
  
  # it "contacts should return a list of photos" do
  #   lambda {@flickr.photos.contacts}.should raise_error(Net::Flickr::APIError,
  #    'Insufficient permissions. Method requires read privileges; none granted.')
  # end
  # 
  # it "should call contacts with an SECRET key and return a list of photos" do
  #   @flickr = Net::Flickr.new(FLICKR_KEY, FLICKR_SECRET)
  #   @flickr.photos.contacts.should be_an_instance_of(Net::Flickr::PhotoList)
  # end
  # 
  # it "recents should return a list of photos" do
  #   @flickr.photos.recent.should be_an_instance_of(Net::Flickr::PhotoList)
  #   @flickr.photos.get_recent.should be_an_instance_of(Net::Flickr::PhotoList)    
  # end
  
  it "should be able to add tags to a photo" do
    pending
  end
  
  it "should be able to delete a photo" do
    pending
  end
  
  it "should throw and catch an exception when permissions are not available to delete and return false" do
    signed_flickr.photos.delete('234242423').should be(false)
  end  
  
  it "should be able to retreive all the sets and pools (contexts) the photo belongs to" do
    signed_flickr.photos.get_all_contexts(FLICKR_PHOTO_ID).should_not be_nil
  end
  
  it "should be able to get all of a user's contact's photos" do
    pending
  end
  
  it "should be able to get all of a user's contact's public photos" do
    pending
  end
  
  it "should be able to get the next and previous photos in a photostream" do
    pending
  end
  
  it "should be able to retrieve a count of photos created or added between certain dates" do
    pending
  end
  
  it "should be able to provide exif data on a photo" do
    pending
  end
  
  it "should be able to retrieve a user's favorites" do
    pending
  end
  
  it "shold be able to get information about a photo" do
    pending
  end
  
  it "should be able to get photos that are not in a given set" do
    pending
  end
  
  it "should be able to get the permissions of a photo" do
    pending
  end
  
  it "should be able to get a list of recent photos uploaded" do
    pending
  end
  
  it "should be able to retrieve a list of sizes for a photo" do
    pending
  end
  
  it "should be able to find your untagged photos" do
    pending
  end
  
  it "should ebe able to find your photos with geo data" do
    pending
  end
  
  it "should be able to find your photos without geo data" do
    pending
  end
  
  it "should find photos that have been recently created or modified" do
    pending
  end
  
  it "should be able to remove a tag from a photo" do
    pending
  end
  
  it "should be able to search for photos" do
    pending
  end
  
  it "should be able to set the content type of a photo" do
    pending
  end
  
  it "should be able to set the dates of a photo" do
    pending
  end
  
  it "should be able to set the meta data of a photo" do
    pending
  end
  
  it "should be able to set the permissions of a photo" do
    pending
  end
  
  it "should be able to set the safety level of a photo" do
    pending
  end

end