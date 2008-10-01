require (File.join(File.dirname(__FILE__), '../spec_helper.rb'))

describe Net::Flickr::Auth do
  include FlickrGeneratorHelper
  
  before do
    @flickr = unsigned_flickr
  end

  # getFrob
  it "should call get_frob and fail when no secret key is provided" do
    lambda {@flickr.auth.get_frob}.should raise_error(Net::Flickr::APIError)
    @flickr.auth.frob.should be_nil
  end
  
  it "should call get_frob and pass when a secret key is provided" do
    f = signed_flickr
    lambda {f.auth.get_frob}.should_not raise_error
    f.auth.frob.should be_an_instance_of(String)
  end
  
  #checkToken
  it "should call checkToken and throw an error if the token is invalid" do
    pending
  end
  
  it "should call checkToken and return true if the token is valid" do
    pending
  end
  
  #getToken
  it "should request getToken, return a string token and set it to the Net::Flickr::Connection object" do
    pending
  end
  
  #getFullToken
  it "should request the full token and set it to Net::Flickr::Connection" do
    pending
  end
  
  it "should call url_webapp and throw an AuthorizationError if an unsigned flickr object is trying to obtain write or delete permissions without a secret key" do
    lambda {@flickr.auth.url_webapp(:write)}.should raise_error(Net::Flickr::AuthorizationError)
    lambda {@flickr.auth.url_webapp(:delete)}.should raise_error(Net::Flickr::AuthorizationError)
  end
  
  # it "should call url_desktop and throw an APIError if an unsigned flickr object is trying to signin without a secret signature" do
  #   lambda {@flickr.auth.url_desktop(:read)}.should raise_error(Net::Flickr::APIError)
  #   lambda {@flickr.auth.url_desktop(:write)}.should raise_error(Net::Flickr::APIError)
  #   lambda {@flickr.auth.url_desktop(:delete)}.should raise_error(Net::Flickr::APIError)
  # end
  
  it "it should throw an APIError when fetching a frob with an invalid api_secret" do
    f = signed_flickr('klsjflksj', '38293uwhfiu2h982h9')
    lambda {f.auth.get_frob}.should raise_error(Net::Flickr::APIError)
  end
  
  after do
    @flickr = nil
  end

end