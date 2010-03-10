# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  # In the form_for scope use: <%= focus_input_field_onload(f, :name) %>
  # In the form_tag scope use: <%= focus_input_field_onload(input_filed_id) %>
  def focus_input_field_onload(f, field_name = nil)
    unless field_name.nil? and f.class == String
      input_field_id = f.object_name + '_' + field_name.to_s
    else
      input_field_id = f
    end
    "<script>$(document).ready(function(){ $('##{input_field_id}').focus(); });</script>"
  end

  #
  # Custom auto complete helper (old one not supported in rails 2)
  #
  # Params:
  #   name, values, html_options just like FormTagHelper::text_field_tag
  #   options for jQuery autocomplete plugin
  #   options[:auto_complete_url]: url to controller answering ajax autocomplete request
  #                                expects controller to return text items separated by \n
  #
  # Source and Reference: http://docs.jquery.com/Plugins/Autocomplete
  #
  # Additional files required:
  #   * jquery.autocomplete.css
  #   * jquery.autocomplete.min.js
  #   * auto_complete_indicator.gif
  #   * jquery.bgiframe.min.js (optional for IE6)
  #
  # Route addition needed (somewhere near top of file)
  # map.connect ':controller/<auto_complete_action>', :action => '<auto_complete_action>'
  #
  def text_field_with_auto_complete(name, value, html_options = {}, options = {})
    options = { :select_first => false,
                :multiple     => true,
                :min_chars    => 2 }.merge options

    result = text_field_tag name, value, html_options
    result += "<script>
                 $(document).ready(function(){
                   var options = { 'selectFirst'   : #{options[:select_first]},
                                   'multiple'      : #{options[:multiple]},
                                   'minChars'      : #{options[:min_chars]} };
                   $(\"##{name}\").autocomplete(\"#{options[:auto_complete_url]}\", options);
                 });
               </script>"
    return result
  end

  def javascript_constant_definition
    # 'const' only works in firefox/safari!
    constant_definition = []
    constant_definition << "var AUTH_TOKEN_PARAM = 'authenticity_token=' + encodeURIComponent(#{form_authenticity_token.inspect});"
    constant_definition << "var PALLET_ID = #{@pallet.id};" if @pallet and @pallet.id
    constant_definition << "var SUB_PATH = '#{@sub_path}';" if @pallet
    return constant_definition.join("\n") 
  end

  def link_to_user_email(user)
    return '' unless user
    if user and not user.email.blank?
      mail_to(user.email, user.login)
    else
      user.login
    end
  end
end
