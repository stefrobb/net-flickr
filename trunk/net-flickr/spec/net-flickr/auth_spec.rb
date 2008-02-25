require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Net::Flickr::Auth do
  
  # provides the methods unsigned_flickr and signed_flickr
  include FlickrGeneratorHelper
  
  it "should call get_frob and fail when no secret key is provided" do
    f = unsigned_flickr
    lambda {f.auth.get_frob}.should raise_error(Net::Flickr::APIError)
    f.auth.frob.should be_nil
  end
  
  it "should call get_frob and pass when a secret key is provided" do
    f = signed_flickr
    lambda {f.auth.get_frob}.should_not raise_error(Net::Flickr::APIError)
    f.auth.frob.should be_an_instance_of(String)
  end
  
  it "should call url_webapp and throw an AuthorizationError if an unsigned flickr object is trying to obtain write or delete permissions without a secret key" do
    f = unsigned_flickr
    lambda {f.auth.url_webapp(:write)}.should raise_error(Net::Flickr::AuthorizationError)
    lambda {f.auth.url_webapp(:delete)}.should raise_error(Net::Flickr::AuthorizationError)
  end
  
  it "should call url_desktop and throw an APIError if an unsigned flickr object is trying to signin without a secret signature" do
    f = unsigned_flickr
    lambda {f.auth.url_desktop(:read)}.should raise_error(Net::Flickr::APIError)
    lambda {f.auth.url_desktop(:write)}.should raise_error(Net::Flickr::APIError)
    lambda {f.auth.url_desktop(:delete)}.should raise_error(Net::Flickr::APIError)
  end
  
  it "should create a nonsense flickr object and throw an APIError when getting an invalid frob" do
    f = signed_flickr('klsjflksj', '38293uwhfiu2h982h9')
    lambda {f.auth.get_frob}.should raise_error(Net::Flickr::APIError)
  end
  
  it "should generate a url when calling url_webapp using bad keys and secrets only Flickr can handle that" do
    f = signed_flickr('klsjflksj', '38293uwhfiu2h982h9')
    f.auth.url_webapp(:delete).should_not be_nil
  end

end