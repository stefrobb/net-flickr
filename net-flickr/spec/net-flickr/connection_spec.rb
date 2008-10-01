require (File.join(File.dirname(__FILE__), '../spec_helper.rb'))

describe Net::Flickr::Connection do

  it "should be able to properly sign a url" do
    conn = Net::Flickr::Connection.new(FLICKR_KEY, FLICKR_SECRET)
    uri = URI.parse(Net::Flickr::Connection::AUTH_URL)
  
    params = {'method'  => 'flickr.auth.getFrob',
              'api_key' => FLICKR_KEY,
              'perms'   => 'read'}

    paramlist = ''
    params.keys.sort.each { |key| 
      paramlist << key << params[key]
    }
  
    unsigned_query = params.to_a.map{|pair| pair[0].to_s + '=' + pair[1].to_s}.join('&')
      
    params['api_sig'] = Digest::MD5.hexdigest(FLICKR_SECRET + paramlist)

    uri.query = unsigned_query
  
    signed_uri = URI.parse(conn.sign_url(uri.to_s))
    api_sig = Hash[*signed_uri.query.split('&').collect{|v| v.split('=')}.flatten]['api_sig']
    api_sig.should == params['api_sig']
  end

  it "should be able to accept and sort parameters in a has with string keys and symbol keys" do
    conn = Net::Flickr::Connection.new(FLICKR_KEY, FLICKR_SECRET)
    lambda {
      @response = conn.request('flickr.test.echo', {:foo => 'bar', 'buckle' => 'shoe'})
    }.should_not raise_error
    
    @response.at('foo').content.should == 'bar'
  end

end

  # it "should not throw an Exception when calling the test.echo method" do
  #  lambda {
  #    @flickr.request('flickr.test.echo')
  #  }.should_not raise_error
  # end
  #
  # it "should call flickr.test.echo and echo back the parameters passed in" do
  #   @response = @flickr.request('flickr.test.echo', {'foo' => 'bar', 'one' => 'two'})
  #   @response.at('foo').inner_text.should == "bar"
  # end
  # 
  # 
  # it "should call flickr.test.echo and use the last 'foo' in the args list when multiple 'foo's are passed in" do
  #   lambda {
  #     @response = @flickr.request('flickr.test.echo', {:foo => 'bar', 'foo' => 'goo'})
  #   }.should_not raise_error
  #   
  #   @response.at('foo').inner_text.should == 'goo'
  # end
  # 
  # it "should call flickr.test.null and throw an error because of missing read permissions" do
  #   lambda {
  #     @flickr.request('flickr.test.null')
  #   }.should raise_error(Net::Flickr::APIError)
  # end