# frozen_string_literal: true

# TODO implement this as a way to resolve data messages in a more discrete way than in the data_message class
#   Could be retained at the top level, or in a new class "Parser" which converts a stream into expanded data objects.
module Fit
  class Profile
    DEFAULT_PROFILE_PATH = File.join(__dir__, '../../profile.json')

    def self.default
      from_json(File.read(DEFAULT_PROFILE_PATH))
    end

    def self.from_json(json)
      new(JSON.parse(json))
    end

    def initialize(profile)
      @profile = profile
    end

    # [param] definition : DefinitionMessage
    # [param] data : Datamessage
    def expand(definition, data)
      # TODO
    end
  end
end
