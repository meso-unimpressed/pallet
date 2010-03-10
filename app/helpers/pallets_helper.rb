module PalletsHelper
  include IE6Detect
  include FileSymbolImageTag

  def current_pallet_name
    @pallet.name || I18n.t('none') rescue I18n.t('none')
  end

  def pallet_navigation_link options = {}
    active_class = options[:active] ? 'active' : ''
    link_to(options[:label],
            options[:url], 
            :title => options[:title],
            :class => active_class,
            :onclick => "self.location=\"#{options[:url]}\";return false")
  end
  
  # generate path links to move up in directory hierarchy
  def path_for sub_path
    sub_path ||= ''
    sub_path = @pallet.name + sub_path
    path = ''
    act_sub_path = ''
    arr_path = sub_path.split('/')
    arr_path.each_with_index do |sub, index|
      if arr_path.length != index + 1 # current element (the last one) is the active one
        css_class = 'ui-corner-top ui-state-default'
      else
        css_class = 'ui-corner-top ui-tabs-selected ui-state-active'
      end
      #logger.debug(sub + ' -- ' + index.to_s + ' // ' + arr_path.length.to_s)
      act_sub_path +=  '/' + sub if index != 0
      if arr_path.length != index + 1
        link = { :action => 'show', :id => @pallet.id, :sub_path => act_sub_path }
        tooltip = "tooltip=\"#{I18n.t('tooltip.move_up')}\" tooltip_opt=\"#{tooltip_options(:position => 'nnw-s')}\""
      else
        link = '#'
        tooltip = ''
      end
      path += "<li class=\"#{css_class}\"#{tooltip}>"
      path += link_to(sub, link)
      path += '</li>'
    end
    path
  end

  # returns /parent/path for /parent/path/sub_path
  def parent_path(path)
    last_slash_pos = path.rindex('/')
    parent_path = last_slash_pos == 0 ? '' : path[0..last_slash_pos - 1]
    
    return parent_path
  end

  # return link for an file element, directories linking to deeper hierarchy
  # files linking to the files itself
  def link_for(element, link_text = nil)
    add_class = link_text.nil?
    link_text ||= element[:original_name]
    case element[:type]
      when 'directory' then return link_to(link_text,
                                           { :action => 'show',
                                             :id => @pallet.id,
                                             :sub_path => "#{@sub_path}/#{element[:original_name]}" },
                                           :class => add_class ? 'directory' : '')
      when 'file'      then return link_to(link_text,
                                           { :action => 'download_file',
                                             :id => @pallet.id,
                                             :filename => element[:original_name],
                                             :sub_path => @sub_path },
                                           :class => add_class ? 'file' : '')
    end
    return link_text
  end
  
  # returns links for deleting an element, with different confirmation texts
  def deletion_link_for element
    if element[:type] == 'directory' or element[:type] == 'file'
      confirm_text = (element[:type] == 'file') ? t('.confirm_delete_file') :
                                                  t('.confirm_delete_directory')

      ui_button_to(:icon => 'trash', 
                   :url => { :action => 'delete',
                             :id => @pallet.id,
                             :sub_path => @sub_path,
                             :type => element[:type],
                             :name => element[:original_name] },
                   :confirm => confirm_text,
                   :class => 'right')
    end
  end
  
  def rename_link_for element
    if element[:type] == 'directory' or element[:type] == 'file'
      ui_button_to(:icon => 'pencil', 
                   :onclick => "open_rename_dialog('#{@sub_path}', '#{element[:original_name]}');
                                return false;",
                   :class => 'right')
    end
  end

  def encrypt_link_for element
    if element[:type] == 'file'
      if File.extname(element[:original_name]) == '.enc'
        action     = 'decryption'
        css_class  = 'decrypt'
        do_decrypt = 'true'
      else
        action     = 'encryption'
        css_class  = 'encrypt'
        do_decrypt = 'false'
      end
      
      return link_to(css_class[0,3],
                     {  },
                     :class => css_class,
                     :onclick => "var password = window.prompt('Enter password for #{action}:', ''); window.status = password;" +
                                 "if(password == '' || password == null) return false; " +
                                 "$('#encrypt_sub_path').attr('value', '#{@sub_path}'); " +
                                 "$('#encrypt_original_filename').attr('value', '#{element[:original_name]}'); " +
                                 "$('#password').attr('value', password); " +
                                 "$('#do_decrypt').attr('value', '#{do_decrypt}'); " +
                                 "$('#encrypt_file').submit(); return false;")
    end
  end
  
  def link_for_order_by(order_by, options = {})
    options = { :class => 'ui-corner-all button left'}.merge(options)
    order_desc = !session[:order_desc] if session[:order_by] == order_by
    order_desc = 'false' if order_desc == false
    
    active_class = session[:order_by] == order_by ? 'ui-state-active' : ''
    direction  = ((session[:order_by] == order_by) and session[:order_desc]) ? 's' : 'n'

    case order_by
      when 'extension' :
        order_by_tooltip = I18n.t('tooltip.file_type')
        tooltip_position = 'nnw-s'
      when 'filename'  :
        order_by_tooltip = I18n.t('tooltip.file_name')
        tooltip_position = 'nnw-s'
      when 'size'      :
        order_by_tooltip = I18n.t('tooltip.file_size')
        tooltip_position = 'n-s'
      when 'timestamp' :
        order_by_tooltip = I18n.t('tooltip.date_time')
        tooltip_position = 'nne-s'
    end

    order_by_tooltip = I18n.t('tooltip.order_by') + ' ' + order_by_tooltip

    if session[:order_by] == order_by
      direction_translated = direction == 'n' ? I18n.t('descending') : I18n.t('ascending')
      order_by_tooltip << '<br />' + I18n.t('tooltip.currently_selected') + '. '
      order_by_tooltip << I18n.t('tooltip.click_to_sort', :direction => direction_translated)
    end
    
    icon = "<span class=\"ui-icon ui-icon-carat-1-#{direction}\"></span>"
    
    result = link_to(icon, { :action => 'show', :id => @pallet.id, :sub_path => @sub_path,
                             :order_by => order_by, :order_desc => order_desc },
                           { :class => active_class + ' ' + options[:class] + ' order_link_button',
                             :tooltip => "#{order_by_tooltip}",
                             :tooltip_opt => tooltip_options(:position => tooltip_position)  })
    return result
  end
  
  def get_size_of element
    number_to_human_size(element[:size]) if element[:type] == 'file'
  end

  def get_time_of element
    l(element[:file_time], :format => :date_time24) if element[:type] == 'file'
  end  
 
  # returns true is the copy_cut session is set and contains at least one copied directory or file
  def valid_file_collection?
    session[@pallet.collection] and not (session[@pallet.collection][:directories].empty? and session[@pallet.collection][:files].empty?)
  end

  def role_access(current_roles, role_id)
    if current_roles.include?(role_id)
      return {
        :authorized => true,
        :container_class=>'granted_access',
        :action => 'revoke_role',
        :action_label => 'revoke access',
        :action_class => 'check',
        :box_class => 'ui-state-highlight'
      }
    else
      return {
        :authorized => false,
        :container_class=>'',
        :action => 'grant_role',
        :action_label => 'grant access',
        :action_class => 'closethick',
        :box_class => 'ui-state-error'
      }
    end
  end

  def user_access(current_users, user_id)
    if current_users.include?(user_id)
      return {
        :authorized => true,
        :container_class => 'granted_access',
        :action => 'revoke_user',
        :action_label => 'revoke access',
        :action_class => 'check',
        :box_class => 'ui-state-highlight'
      }
    else
      return {
        :authorized => false,
        :container_class => '',
        :action => 'grant_user',
        :action_label => 'grant access',
        :action_class => 'closethick',
        :box_class => 'ui-state-error'
      }
    end
  end

end
