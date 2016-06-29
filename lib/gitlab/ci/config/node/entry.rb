module Gitlab
  module Ci
    class Config
      module Node
        ##
        # Base abstract class for each configuration entry node.
        #
        class Entry
          class InvalidError < StandardError; end

          attr_writer :key
          attr_reader :config
          attr_accessor :parent, :description

          def initialize(config)
            @config = config
            @nodes = {}
            @validator = self.class.validator.new(self)
            @validator.validate
          end

          def process!
            return if leaf?
            return unless valid?

            compose!
            process_nodes!
          end

          def nodes
            @nodes.values
          end

          def leaf?
            self.class.nodes.none?
          end

          def key
            @key || self.class.name.demodulize.underscore
          end

          def valid?
            errors.none?
          end

          def errors
            @validator.messages + nodes.flat_map(&:errors)
          end

          def value
            @config
          end

          def defined?
            true
          end

          def self.default
          end

          def self.nodes
            {}
          end

          def self.validator
            Validator
          end

          private

          def compose!
            self.class.nodes.each do |key, essence|
              @nodes[key] = create_node(key, essence)
            end
          end

          def process_nodes!
            nodes.each(&:process!)
          end

          def create_node(key, essence)
            raise NotImplementedError
          end
        end
      end
    end
  end
end
