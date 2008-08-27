module Net
  class Flickr
    class Connection

      AUTH_URL      = 'http://flickr.com/services/auth/'.freeze
      REST_ENDPOINT = 'http://api.flickr.com/services/rest/'.freeze
  
      attr_accessor :key, :secret, :token
  
      def initialize(key, secret=nil, token=nil)
        @key, @secret, @token = key, secret, token
      end
  
      # Calls the specified Flickr REST API _method_ with the supplied
      # arguments and returns a Flickr REST response in XML format. If an
      # API secret is set, the request will be properly signed.
      def request(method, args={})
        params = {}
        args.each_key{|key| params[key.to_s] = args[key].to_s}
        params.merge!({'method' => method, 'api_key' => @key})
  
        url     = URI.parse(REST_ENDPOINT)
        http    = Net::HTTP.new(url.host, url.port)
        request = sign_request(Net::HTTP::Post.new(url.path), params)
      
        http.start do |http|
          if block_given?
            http.request(request) { |response| yield response }
          else
            response = http.request(request)
      
            # Raise a Net::HTTP error if the HTTP request failed.
            unless response.is_a?(Net::HTTPSuccess) || 
                response.is_a?(Net::HTTPRedirection)
              response.error!
            end

            parse(response.body)
          end
        end
      end

      # Signs a Flickr URL with the API secret.
      # This is only called in:
      # flickr.auth.url_webapp,
      # flickr.auth.url_desktop
      def sign_url(url)
        if @secret.nil?
          raise AuthorizationError,
                'An API secret key is required to sign a url.'      
        end

        uri = URI.parse(url)
        params = uri.query.split('&')
        params << 'api_sig=' + Digest::MD5.hexdigest(@secret +
            params.sort.join('').gsub('=', ''))
        uri.query = params.join('&')
        uri.to_s
      end

      # Signs a Flickr API request with the API secret if set.
      def sign_request(request, params)
        raise AuthorizationError, 'An API key is required.' if @key.nil?

        # If the secret isn't set, we can't sign anything.
        if @secret.nil?
          request.set_form_data(params)
          return request
        end

        # Add auth_token to the param list if we're already authenticated.
        params['auth_token'] = @token if @token

        # Build a sorted, concatenated parameter list as described at
        # http://flickr.com/services/api/auth.spec.html
        paramlist = ''
        params.keys.sort.each do |key|
          params[key].gsub!(' ', '+')
          paramlist << key << URI.escape(params[key])
        end

        # Sign the request with a hash of the secret key and the
        # concatenated parameter list.
        params['api_sig'] = Digest::MD5.hexdigest(@secret + paramlist)
    
        request.set_form_data(params)
        request      
      end
      
      # Attempts to parse a valid XML response from Flickr.
      # If it fails to either find a valid document or fails to get a valid
      # response from Flickr it throws an error.
      def parse(response_xml)
        begin
          xml = LibXML::XML::Parser.string(response_xml).parse
        rescue => e
          raise InvalidResponse,
                'Invalid Flickr API response: ' + e.message
        end
      
        unless response = xml.find_first('/rsp')
          raise InvalidResponse,
                'Invalid Flickr API response: missing rsp tag'
        end
      
        if response.find_first('/rsp/@stat').value == 'ok'
          return response
        elsif response.find_first('/rsp/@stat').value == 'fail'
          raise APIError, response.find_first('/rsp/err/@msg').value
        else
          raise InvalidResponse,
                'Invalid Flickr API response'
        end
      end

    end # Net::Flickr::Connection
  end
end