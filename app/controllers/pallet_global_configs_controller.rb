class PalletGlobalConfigsController < ApplicationController
  include ServerAddressDetector
  
  require_login :role => 'system_admin'

  layout 'common'
  
  # GET /pallet_global_configs/1/edit
  def edit
    @pallet_global_config = PalletGlobalConfig.first

    @domain_suggestion = server_address
  end

  # PUT /pallet_global_configs/1
  # PUT /pallet_global_configs/1.xml
  def update
    @pallet_global_config = PalletGlobalConfig.first

    respond_to do |format|
      if @pallet_global_config.update_attributes(params[:pallet_global_config])
        flash[:notice] = t('flash.system_config_updated_successfully')
        format.html { redirect_to(pallet_global_configs_url) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @pallet_global_config.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def grant_role
    PalletAutoAssociatedRole.new(:role_id => params[:role_id]).save
    render_roles_partial
  end

  def revoke_role
    PalletAutoAssociatedRole.find_by_role_id(params[:role_id]).destroy
    render_roles_partial
  end

  def render_roles_partial
    render :partial => 'pallets/roles', :locals => { :controller_name   => 'pallet_global_configs',
                                                     :current_roles     => PalletGlobalConfig.auto_associated_role_ids,
                                                     :show_admin_roles  => (params[:show_admin_roles]  == 'true'),
                                                     :show_pallet_roles => (params[:show_pallet_roles] == 'true') }
  end
end
