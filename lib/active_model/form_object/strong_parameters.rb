module ActiveModel
  module FormObject
    module StrongParameters

      def self.included(klass)
        klass.extend(ClassMethods)
        attr_accessor :unpermitted_attrs
      end

      module ClassMethods
        def strong_parameters(parameter_name, opts = {})
          if opts == {}
            opts = parameter_name
            parameter_name = :params
          end

          StrongParameters.new(self).set(parameter_name, opts)
        end
      end

      class StrongParameters
        attr_accessor :klass

        def initialize(klass)
          @klass = klass
        end

        def set(parameter_name, opts)
          opts.each do |key, value|
            klass.send(:define_method, "#{key}_params".to_sym) do
              params = self.send(parameter_name)

              unless params[key].nil?
                self.unpermitted_attrs ||= {}
                unpermitted = params[key].keys.map(&:to_s) - value.map(&:to_s)
                self.unpermitted_attrs[key] = unpermitted if unpermitted.any?
              end

              params.require(key).permit(value)
            end
          end
        end
      end
    end
  end
end

