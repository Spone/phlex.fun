# frozen_string_literal: true

module Phlex
	module Renderable
		def render(renderable, *args, **kwargs, &block)
			if renderable.is_a?(HTML)
				if block_given? && !block.binding.receiver.is_a?(Phlex::Block)
					block = Phlex::Block.new(self, &block)
				end

				renderable.call(@_target, view_context: @_view_context, parent: self, &block)
			elsif renderable.is_a?(Class) && renderable < Phlex::HTML
				raise ArgumentError, "You tried to render the Phlex view class: #{renderable.name} but you probably meant to render an instance of that class instead."
			else
				@_target << @_view_context.render(renderable, *args, **kwargs, &block)
			end

			nil
		end

		def render_in(view_context, &block)
			if block_given?
				call(view_context: view_context) do |*args, **kwargs|
					view_context.with_output_buffer(self) do
						original_length = @_target.length
						output = yield(*args, **kwargs)
						unchanged = (original_length == @_target.length)

						if unchanged
							if defined?(ActiveSupport::SafeBuffer) && output.is_a?(ActiveSupport::SafeBuffer)
								unsafe_raw(output)
							else
								text(output)
							end
						end
					end
				end.html_safe
			else
				call(view_context: view_context).html_safe
			end
		end

		def format
			:html
		end
	end
end