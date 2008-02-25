require File.dirname(__FILE__) + '/spec_helper.rb'

describe Net::Flickr::Photos do

  before do
    @flickr = Net::Flickr.new(FLICKR_API_KEY)
  end
  
  it "should be a flickr object" do
    @flickr.should be_an_instance_of(Net::Flickr)
  end
  
  after do
    @flickr = nil
  end

end

describe Net::Flickr::Photo do

  before do
    @flickr = Net::Flickr.new(FLICKR_API_KEY)
  end
  
  it "contacts should return a list of photos" do
    lambda {@flickr.photos.contacts}.should raise_error(Net::Flickr::APIError,
     'Insufficient permissions. Method requires read privileges; none granted.')
  end
  
  it "recents should return a list of photos" do
    @flickr.photos.recent.should be_an_instance_of(Net::Flickr::PhotoList)
    @flickr.photos.get_recent.should be_an_instance_of(Net::Flickr::PhotoList)    
  end
  
end