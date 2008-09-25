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
  
  it "should throw an APIError if the Flickr API key is not valid" do
    conn = Net::Flickr::Connection.new('324234234')
    lambda {
      conn.request('flickr.test.echo') 
    }.should raise_error(Net::Flickr::APIError)
  end

end