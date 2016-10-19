require_relative 'slack_lib'
require_relative 'zkill_lib'

# A worker that continuously polls Zkillboard for new kills and posts them to Slack if they meet posting criteria.
class Worker
  # Poll for new kills continuously and post them to Slack if they meet posting criteria.
  def process_kills
    zkill_lib = ZkillLib.new
    slack_lib = SlackLib.new

    loop do
      # Retrieve a kill from Zkillboard.
      kill = zkill_lib.retrieve_kill

      # If the kill is nil, there were no new kills to retrieve.
      next if kill.nil?

      # If the kill involves HK, post it to the HK kills channel.
      if kill.involves_hk?
        slack_lib.post_message_to_intel(zkill_lib.zkill_link_for_kill_id(kill.id))
      end

      # If the kill involes a large wspace victim, post it to the wspace kills channel.
      if kill.in_wspace? && (kill.victim_was_capital? || kill.victim_was_large_citadel?)
        slack_lib.post_message_to_intel(zkill_lib.zkill_link_for_kill_id(kill.id))
      end
    end
  end
end
