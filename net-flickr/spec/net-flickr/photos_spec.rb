require File.dirname(__FILE__) + '/spec_helper.rb'

describe Net::Flickr::Photos do

  before do
    @flickr = Net::Flickr.new(FLICKR_API_KEY)
  end
  
  it "contacts should return a list of photos" do
    lambda {@flickr.photos.contacts}.should raise_error(Net::Flickr::APIError,
     'Insufficient permissions. Method requires read privileges; none granted.')
  end
  
  it "should call contacts with an SECRET key and return a list of photos" do
    @flickr = Net::Flickr.new(FLICKR_API_KEY, FLICKR_SECRET)
    @flickr.photos.contacts.should be_an_instance_of(Net::Flickr::PhotoList)
  end
  
  it "recents should return a list of photos" do
    @flickr.photos.recent.should be_an_instance_of(Net::Flickr::PhotoList)
    @flickr.photos.get_recent.should be_an_instance_of(Net::Flickr::PhotoList)    
  end
  
end