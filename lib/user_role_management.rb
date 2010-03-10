module UserRoleManagement
  # update div with users for a PALLET, using appropriate parametes
  def pallet_users
    @pallet ||= Pallet.find(params[:id])
    render :partial => 'users', :locals => { :current_users => @pallet.standard_role_user_ids,
                                             :id => @pallet.id,
                                             :show_admin_users => params[:show_admin_roles] == 'false',
                                             :scope => params[:scope] }
  end

  # update div with users for a ROLE, using appropriate parametes
  def role_users
    @role ||= Role.find(params[:id])
    render :partial => 'users', :locals => { :current_users => @role.users.map{|r| r.id},
                                             :id => @role.id,
                                             :scope => params[:scope] }
  end
  
  def grant_user
    if params[:scope] == 'pallets'
      User.find(params[:user_id]).add_roles Pallet.find(params[:id]).standard_role
      pallet_users
    else
      User.find(params[:user_id]).add_roles params[:id]
      role_users
    end
  end
  
  def revoke_user
    if params[:scope] == 'pallets'
      User.find(params[:user_id]).remove_roles Pallet.find(params[:id]).standard_role
      pallet_users
    else
      User.find(params[:user_id]).remove_roles params[:id]
      role_users
    end
  end
  
  def roles
    @pallet ||= Pallet.find(params[:id])
    render :partial => 'roles', :locals => { :controller_name => 'pallets',
                                             :id => @pallet.id,
                                             :current_roles => @pallet.role_ids,
                                             :show_admin_roles => params[:show_admin_roles] == 'false',
                                             :show_pallet_roles => params[:show_pallet_roles] == 'false' }
  end
  
  def grant_role
    @pallet = Pallet.find(params[:id])
    @pallet.roles << Role.find(params[:role_id])
    roles
  end
  
  def revoke_role
    @pallet = Pallet.find(params[:id])
    role = Role.find(params[:role_id])
    unless @pallet.standard_role.id == role.id
      @pallet.roles.delete role
    else
      flash[:error] = t('flash.cant_remove_standard_role')
    end
    roles
  end
    
  
  
protected



  # iterates over user_associations, tries to find users by login and remaining by email address
  # still not found strings will be used to create accounts, if those strings are email addresses
  def associate_users
    found_user_count = 0
    created_user_count = 0
    flash[:notice] = ''
    flash[:error] = ''

    pallet_standard_role = Role.find_by_title(@pallet.standard_role_name)

    user_identifier_list = params[:pallet_user_association].split(',').collect{ |m| m.strip } rescue []
    user_identifier_list.delete ''

    #logger.debug "\n===> #{user_identifier_list.to_yaml}\n\n==========================================\n"

    # try to find by login and email address
    #logger.debug "\n===> try to find by login and email address\n"
    for column in ['name', 'email']
      matches = []
      for user_identifier in user_identifier_list
        #logger.debug "\n===> #{user_identifier}\n"
        user = User.find(:first, :conditions => [ "#{column} = ?", user_identifier])
        if user
          # only add and count user if not assigned in last iteration or column
          unless pallet_standard_role.users.include? user
            pallet_standard_role.users << user
            found_user_count += 1
          end
          matches << user_identifier
        end
      end
      # remove matches per column
      matches.each { |m| user_identifier_list.delete m }
    end
    if found_user_count > 0
      # TODO: translation needed
      flash[:notice] += t('flash.users_found_and_associated', 
                          :users => 'user'.pluralize_by(found_user_count, :number => true) + ' ' + 
                                    'was'.pluralize_by(found_user_count, :plural => 'were'))
    end

    # process remaining strings
    #logger.debug "\n===> process remaining strings\n"
    for user_identifier in user_identifier_list
      if user_identifier.valid_email_address?
        #logger.debug "\n===> #{user_identifier}\n"
        pallet_standard_role.users << create_new_user(user_identifier, @pallet.standard_role)
        created_user_count += 1
      else
        flash[:error] += t('flash.user_ignored', :name => user_identifier)
      end
    end
    if created_user_count > 0
      # TODO: translation needed
      flash[:notice] += t('flash.users_created_and_associated', 
                          :users => 'user'.pluralize_by(created_user_count, :number => true) + ' ' +
                                    'was'.pluralize_by(created_user_count, :plural => 'were'))
    end
    #logger.debug "\n===> #{flash[:notice]}\n"
    #logger.debug "\n===> #{flash[:error]}\n"
  end

  def create_new_user(email, role = nil)
    password = generate_nice_password
    user = User.new( :login => email,
                     :email => email,
                     :password => password,
                     :password_confirmation => password )
    user.save!

    # add user role for this user if set
    user.add_roles Role.find_by_title(role)
    
    #UserNotifier.deliver_signup_notification(user)

    return user
  end  
end
