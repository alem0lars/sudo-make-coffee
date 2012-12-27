require 'singleton'


module Ipc
  module Spec
    class Msgs
      include Singleton

      def quit
        { 'kind' => 'cmd',
          'value' => 'quit'
        }
      end

      def logging(text)
        { 'kind' => 'logging',
          'value' => text
        }
      end

    end
  end
end
