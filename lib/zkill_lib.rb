require 'httpclient'
require 'json'
require_relative 'invalid_kill_data_error'
require_relative 'kill'

# Class used to communicate with Zkillboard.
class ZkillLib
  # Default URL to poll for kills.
  QUEUE_URL = 'https://redisq.zkillboard.com/listen.php'.freeze

  # Base URL for kills.
  KILL_URL_BASE = 'https://zkillboard.com/kill/'.freeze

  # Configure the class to poll the specified queue.
  def initialize(queue_url = QUEUE_URL)
    @queue_url = queue_url
    @http_client = HTTPClient.new
  end

  # Retrieve a single kill from Zkillboard.
  def retrieve_kill
    response = nil

    begin
      response = @http_client.get_content(@queue_url)
    rescue HTTPClient::BadResponseError, HTTPClient::ConfigurationError, HTTPClient::TimeoutError
      # Ignore the error so that we continue polling.
      return nil
    end

    begin
      response_json = JSON.parse(response)

      # If response['package'] isn't set then there aren't any new kills.
      return nil unless response_json['package']

      # Otherwise, there has been a kill, return it.
      return Kill.new(response_json['package'])
    rescue JSON::ParserError, InvalidKillDataError
      # Ignore the error so that we continue polling.
      return nil
    end
  end

  # Returns a link to a kill on Zkillboard.
  def zkill_link_for_kill_id(kill_id)
    "#{KILL_URL_BASE}#{kill_id}"
  end
end
