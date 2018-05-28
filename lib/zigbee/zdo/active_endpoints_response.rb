require_relative '../../utils'
require_relative './zdo_command'

module Zigbee
  module ZDO
    class ActiveEndpointsResponse < ZDOCommand
      include ArrayUtils
    end
  end
end
