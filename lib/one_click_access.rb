module OneClickAccess
  
  #TODO: is this used anywhere in a request?
  def one_click_access_list
    @pallet = Pallet.find(params[:id])
    render :partial => 'one_click_access'
  end
  
  def dialog_one_click_access
    @pallet = Pallet.find(params[:id])
    set_sub_path_from_params

    render :update do |page|
      page.replace_html 'one_click_access', :partial => 'one_click_access_form'
    end
  end

  def add_one_click_access
    @pallet = Pallet.find(params[:pallet_one_click_access][:pallet_id])
    return if one_click_access_generation_denied?

    oca = PalletOneClickAccess.new(params[:pallet_one_click_access])
    oca.user_id = current_user.id
    
    if oca.save
      flash[:notice] = t('flash.oca_created')
    end
  
    begin
      oca.invite_email_receivers
    rescue Exception => e
      flash[:error] = t('flash.oca_mailer_exception') + e.message
    end

    @sub_path = params[:pallet_one_click_access][:sub_path]
  end
  
  def destroy_one_click_access
    poca = PalletOneClickAccess.find(params[:id])
    @pallet = poca.pallet
    return if one_click_access_generation_denied?
    poca.destroy
  end

  # One-Click-Access may only be touched by common users for workgroups, 
  # which allow that explicitly.
  # Admins may do it of course, too.
  def one_click_access_generation_denied?
    unless one_click_access_generation_allowed?
      render :text => 'Access denied.'
      return true
    else
      return false
    end
  end
  
  # helper_method :one_click_access_generation_allowed? set in pallets_controller
  def one_click_access_generation_allowed?
    logged_in? and (@pallet.one_click_access_generation_by_users? or 
                    current_user.has_role? 'admin')
  end

end
