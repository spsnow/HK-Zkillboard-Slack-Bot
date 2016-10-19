require_relative 'invalid_pilot_data_error'

# Class used to represent a pilot.
class Pilot
  HKRAB_ALLIANCE_ID = 99005065

  # Create a new pilot.
  def initialize(pilot_json)
    @logger = Logger.new(STDOUT)

    # Character isn't defined if the pilot is an NPC/Structure.
    return unless pilot_json['character']

    begin
      @id = pilot_json.fetch('character').fetch('id')
      @name = pilot_json.fetch('character').fetch('name')
    rescue KeyError
      # The structure of the pilot JSON was not what we expected.
      @logger.fatal("Unable to create Pilot from JSON: #{pilot_json}")
      raise InvalidPilotDataError
    end

    # If the pilot is in a corporation, save that data.
    if pilot_json.fetch('character')['corporation']
      @corporation_id = pilot_json.fetch('corporation').fetch('id')
      @corporation_name = pilot_json.fetch('corporation').fetch('name')
    end

    # If the pilot is in an alliance, save that data.
    return if pilot_json.fetch('character')['alliance'].nil?

    @alliance_id = pilot_json.fetch('character').fetch('alliance').fetch('id')
    @alliance_name = pilot_json.fetch('character').fetch('alliance').fetch('name')
  end

  # Returns true iff a pilot is in HKRAB.
  def in_hk?
    @alliance_id == HKRAB_ALLIANCE_ID
  end
end
