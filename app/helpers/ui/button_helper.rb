module Ui::ButtonHelper
  def ui_button_to(options = {})
    options = { :url     => '#',
                :icon    => 'help',
                :label   => '',
                :id      => '',
                :class   => '',
                :title   => '',
                :tooltip => nil,
                :tooltip_opt => nil,
                :type    => 'button',
                :active  => false,
                :confirm => false,
                :onclick => '',
                :remote  => false,
                :update  => nil,
                :method  => nil}.merge options

    if options[:type] == 'button'
      icon_span = "<span class=\"ui-icon ui-icon-#{options[:icon]}\"></span>"
      link_label = icon_span + options[:label]
      css_class = options[:label].blank? ? '' : "ui-corner-all button-icon-text "
      css_class << options[:class]
      css_class.gsub!('ui-state-default', 'ui-state-active') if options[:active] === true
    elsif options[:type] == 'toggle-box'
      icon_span = "<span class=\"ui-icon ui-icon-#{options[:icon]} left \"></span>"
      link_label = icon_span + '<span class="left title">' + options[:title] + '</span>'
      css_class = options[:label].blank? ? '' : "ui-state-error ui-corner-all left"
      css_class << options[:class]
    end
    unless options[:remote]
      link_to(link_label,
              options[:url],
              :id      => options[:id],
              :class   => css_class,
              :title   => options[:title],
              :tooltip => options[:tooltip],
              :tooltip_opt => options[:tooltip_opt],
              :onclick => options[:onclick],
              :confirm => options[:confirm])
    else
      link_to_remote(link_label,
                     { :update  => options[:update],
                       :url     => options[:url],
                       :confirm => options[:confirm],
                       :method  => options[:method]},
                     { :id      => options[:id],
                       :class   => css_class,
                       :title   => options[:title],
                       :tooltip => options[:tooltip],
                       :tooltip_opt => options[:tooltip_opt],
                       :onclick => options[:onclick] })
    end
  end
end
