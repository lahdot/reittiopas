class Reittiopas

# Reittiopas::HTTP is initialized with account details upon initialization
# of a Reittiopas object.
#
# Since Reittiopas API is to be queried using
# GET requests with appropriate query parameters, Reittiopas::HTTP exists
# to simplify the process by offering a +get+ method that accepts a hash
# containing the query parameters as an argument.
#
class HTTP
  # Base URI for the Reittiopas API service.
  API_BASE_URI = "http://api.reittiopas.fi/public-ytv/fi/api/"

  # Addressable::URI instance of the API URI with account details set as
  # query parameters.
  attr_reader :api_uri

  # Create a new Reittiopas::HTTP object.
  #
  # [account] A hash containing the keys +:username+ and +:password+ with
  #           their respective values.
  def initialize(account)
    @api_uri = Addressable::URI.parse(API_BASE_URI)
    @api_uri.query_values = {:user => account[:username], :pass => account[:password]}
  end

  # Send a GET request to the API with account details and +opts+ as query
  # parameters.
  #
  # [opts] A hash containing query parameters. Values are automatically
  #        encoded by Addressable::URI.
  def get(opts)
    raise ArgumentError if opts.empty?
    uri = @api_uri.dup
    opts.merge!(opts){ |k,ov| ov.to_s } # Coordinates to string
    uri.query_values = uri.query_values.merge(opts)

    # TODO ugly workaround until addressable's author updates the game
    body = Net::HTTP.get(URI.parse(uri.to_s))

    # API responses with 200 OK in case of invalid account, so...
    if body =~ /No rights to access API./
      raise AccessError, 'Most likely due to invalid account details'
    end

    body
  end
end
end
