require File.dirname(__FILE__) + '/spec_helper.rb'

describe Net::Flickr::Test do

  before do
    @flickr = Net::Flickr.new(FLICKR_API_KEY)
  end
  
  it "should call test.echo and say foo" do
    response = @flickr.test.echo({'foo'=>'foo'})
    response.at("foo").inner_text.should == "foo"
  end
  
  it "should call flickr.test.null and throw an error because of read permissions" do
    lambda {@flickr.test.null}.should raise_error(Net::Flickr::APIError)
  end
  
  after do
    @flickr = nil
  end

end