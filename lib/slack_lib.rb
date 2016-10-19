# Class used to communicate with Slack.
class SlackLib
  # URL to use to post messages.
  # Ref: https://api.slack.com/methods/chat.postMessage
  POST_MESSAGE_URL = 'https://slack.com/api/chat.postMessage'.freeze

  def initialize
    @http_client = HTTPClient.new
    @slack_token = File.read('configuration/slack.txt').strip
  end

  def post_message_to_intel(text)
    post_message('intel-public', text)
  end

  private

  # Posts a message to a channel.
  def post_message(channel_name, text)
    @http_client.post(
      POST_MESSAGE_URL,
      {
        token: @slack_token,
        as_user: true,
        channel: channel_name,
        text: text
      }
    )
  end
end
