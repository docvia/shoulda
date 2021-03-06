module Shoulda # :nodoc:
  module ActionController # :nodoc:
    module Matchers

      # Ensures that the flash contains the given value. Can be a String, a
      # Regexp, or nil (indicating that the flash should not be set).
      #
      # Example:
      #
      #   it { should set_the_flash }
      #   it { should set_the_flash.to("Thank you for placing this order.") }
      #   it { should set_the_flash.to(/created/i) }
      #   it { should set_the_flash.to(/logged in/i).now }
      #   it { should_not set_the_flash }
      def set_the_flash
        SetTheFlashMatcher.new
      end

      class SetTheFlashMatcher # :nodoc:

        def to(value)
          @value = value
          self
        end

        def now
          @now = true
          self
        end

        def matches?(controller)
          @controller = controller
          sets_the_flash? && string_value_matches? && regexp_value_matches?
        end

        attr_reader :failure_message, :negative_failure_message

        def description
          description = "set the flash"
          description << " to #{@value.inspect}" unless @value.nil?
          description
        end

        def failure_message
          "Expected #{expectation}"
        end

        def negative_failure_message
          "Did not expect #{expectation}"
        end

        private

        def sets_the_flash?
          !flash.blank?
        end

        def string_value_matches?
          return true unless String === @value
          flash.to_hash.values.any? {|value| value == @value }
        end

        def regexp_value_matches?
          return true unless Regexp === @value
          flash.to_hash.values.any? {|value| value =~ @value }
        end

        def flash
          return @flash if @flash
          flash_and_now = @controller.request.session["flash"].dup if @controller.request.session["flash"]
          flash         = @controller.send(:flash)

          @flash = if @now
            flash.keys.each {|key| flash_and_now.delete(key) }
            flash_and_now
          else
            flash
          end
        end

        def expectation
          expectation = "the flash#{".now" if @now} to be set"
          expectation << " to #{@value.inspect}" unless @value.nil?
          expectation << ", but #{flash_description}"
          expectation
        end

        def flash_description
          if flash.blank?
            "no flash was set"
          else
            "was #{flash.to_hash.inspect}"
          end
        end

      end

    end
  end
end
