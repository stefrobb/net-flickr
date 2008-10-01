require (File.join(File.dirname(__FILE__), '../spec_helper.rb'))

describe Net::Flickr do
  include FlickrGeneratorHelper
  
  it "should only accept a Net::Flickr::Connection object at the connection setter" do
    lambda { Net::Flickr.connection = '' }.should raise_error(Exception)
    lambda { Net::Flickr.connection = Net::Flickr::Connection.new('1','2','3') }.should_not raise_error(Exception)
  end
end