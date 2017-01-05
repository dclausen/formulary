require "json"

module Formulary
  module Form
    def self.included(base)
      base.include(InstanceMethods)
      base.include(::ActiveModel::Validations)
    end

    module InstanceMethods
      def name
        self.class.to_s.sub("Form", "").downcase
      end

      def action
        "/"
      end

      def method
        "GET"
      end

      def renderer
        BootstrapV3
      end

      def render
        renderer.new(self).render
      end

      def model
        @model
      end

      def attribute(name, type, options = {}, validations = {})
        @model ||= []
        @model << {
          name: name,
          type: type,
          options: options,
          validations: validations
        }

        self.class.send(:attr_accessor, name)
        validations.each do |validation,argument|
          self.class.validates name, { validation => argument }
        end
      end

      def to_json
        @model.to_json
      end

      def from_json(string)
        JSON.parse(string).each do |attr|
          attribute(attr["name"], attr["type"], attr["options"], attr["validations"])
        end
      end
    end
  end
end
