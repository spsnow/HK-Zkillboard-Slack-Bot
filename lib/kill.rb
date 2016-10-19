require 'logger'
require_relative 'invalid_kill_data_error'
require_relative 'invalid_pilot_data_error'
require_relative 'pilot'

# Class used to represent a kill.
class Kill
  attr_reader :id
  # In Eve, all of the wspace systems have a system id greater than this one.
  # Ref: https://www.fuzzwork.co.uk/dump/sde-20161011-TRANQUILITY/mapSolarSystemJumps.csv.bz2
  LOWEST_WSPACE_SYSTEM_ID = 31000000

  # A list of ShipType ids for all capitals.
  CAPITAL_SHIP_TYPE_IDS = [
    37604, 42242, 37606, 37605, 37607, 42133,
    23757, 23915, 24483, 23911, 42132, 42243,
    34345, 42124, 19724, 34339, 19722, 34341,
    19726, 34343, 19720
  ].freeze

  FORTIZAR_SHIP_TYPE_ID = 35833

  KEEPSTAR_SHIP_TYPE_ID = 35834

  # Create a new kill using JSON from Zkillboard.
  def initialize(kill_json)
    begin
      @logger = Logger.new(STDOUT)
      @id = kill_json.fetch('killID')
      @system_name = kill_json.fetch('killmail').fetch('solarSystem').fetch('name')
      @system_id = kill_json.fetch('killmail').fetch('solarSystem').fetch('id')
      @kill_time = kill_json.fetch('killmail').fetch('killTime')
      @victim = Pilot.new(kill_json.fetch('killmail').fetch('victim'))
      @victim_ship_type_id = kill_json.fetch('killmail').fetch('victim').fetch('shipType').fetch('id')
      @attackers = kill_json.fetch('killmail').fetch('attackers').map { |attacker| Pilot.new(attacker) }
    rescue KeyError, InvalidPilotDataError
      # The structure of the pilot JSON was not what we expected.
      @logger.fatal("Unable to create Kill from JSON: #{kill_json}")
      raise InvalidKillDataError
    end

    raise InvalidKillDataError unless valid?
  end

  # Returns a boolean indicating whether or not this kill is valid.
  def valid?
    return false if @id.nil?
    return false if @system_name.nil?
    return false if @kill_time.nil?

    true
  end

  # Returns true iff the kill involves HKRAB.
  def involves_hk?
    return true if @victim.in_hk?

    return true if @attackers.any?(&:in_hk?)

    false
  end

  # Returns true iff the kill occurred in wspace.
  def in_wspace?
    @system_id >= LOWEST_WSPACE_SYSTEM_ID
  end

  # Returns true iff the kill was a capital dying.
  def victim_was_capital?
    CAPITAL_SHIP_TYPE_IDS.include?(@victim_ship_type_id)
  end

  # Returns true iff the kill was a Keepstar or Fortizar dying.
  def victim_was_large_citadel?
    @victim_ship_type_id == FORTIZAR_SHIP_TYPE_ID ||
     @victim_ship_type_id == KEEPSTAR_SHIP_TYPE_ID
  end
end
