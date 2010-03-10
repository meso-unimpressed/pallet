module Ui::TooltipHelper
  #
  # Helper to create an javascript options object, compatible to qtip.initialize.js
  #
  # The JavaScript wants a tooltip attribute defined, which is used as tooltip text.
  # An optional tooltip_opts attribute allows to set qtip options.
  # Currently not all options are supported by this helper.
  #
  # There are some custom parameters, which are not supported by qtip directly, but by the JavaScript,
  # i.e. skip_init and auto_hide
  #
  # link_to('test', '/test', :tooltip => 'Hello', :tooltip_opt => tooltip_options(:show_delay => 500)
  #
  def tooltip_options(options = {})
    tooltip_options = []

    if options[:position] and options[:position].index('-') 
      position = options[:position].split('-')

      position.each_with_index do |direction, index|
        direction = case direction.downcase
          when 'nnw' : 'topLeft'
          when 'n'   : 'topMiddle'
          when 'nne' : 'topRight'

          when 'ene' : 'rightTop'
          when 'e'   : 'rightMiddle'
          when 'ese' : 'rightBottom'

          when 'sse' : 'bottomRight'
          when 's'   : 'bottomMiddle'
          when 'ssw' : 'bottomLeft'

          when 'wsw' : 'leftBottom'
          when 'w'   : 'leftMiddle'
          when 'wnw' : 'leftTop'
        end
        position[index] = direction
      end
      arrow_from, arrow_to = position
      tooltip_options << "position: { corner: { target: '#{arrow_to}', tooltip: '#{arrow_from}' } }"
    end

    group_options = []
    %w{delay ready solo}.each do |option|
      key = ('show_' + option).to_sym
      value = %w{true false}.include?(options[key].to_s) ? options[key] : "'#{options[key]}'"
      group_options << "#{option}: #{value}" if options[key]
    end
    tooltip_options << "show: { #{group_options.join(', ')} }" unless group_options.empty?

    group_options = []
    %w{fixed when}.each do |option|
      key = ('hide_' + option).to_sym
      value = %w{true false}.include?(options[key].to_s) ? options[key] : "'#{options[key]}'"
      group_options << "#{option}: #{value}" if options[key]
    end
    tooltip_options << "hide: { #{group_options.join(', ')} }" unless group_options.empty?

    tooltip_options << "content: { url: '#{options[:url]}' }" if options[:url]


    #### ###  ##  #
    # custom parameters. ignored by tooltip, but used by qtip.initialize.js

    # skips automatic initialization
    tooltip_options << "skip_init: true" if options[:skip_init]

    # automatically hide this tooltip after specified time (useful with show_ready option)
    tooltip_options << "auto_hide: #{options[:auto_hide]}" if options[:auto_hide]
    # /custom parameters
    #### ###  ##  #

    # merge object strings together
    result = "{ #{tooltip_options.join(', ')} }"

    #logger.debug "\n===> #{result}\n"

    return result
  end
end
