class RolesController < ApplicationController
  require_login :role => 'admin'

  layout 'common'

  def index    
    @roles = Role.find(:all)
  end

  def new
    @role = Role.new
  end

  def create
    @role = Role.new(params[:role])
    if @role.save
      flash[:notice] = t('flash.role_created')
      redirect_to roles_path
    else
      render :action => 'new'
    end
  end

  def edit
    @role = Role.find(params[:id])
  end

  def update
    @role = Role.find(params[:id])
    if @role.update_attributes(params[:role])
      flash[:notice] = t('flash.role_updated')
      redirect_to roles_path

    else
      render :action => 'edit'
    end
  end

  def delete
    Role.find(params[:id]).destroy
    # destroy dependent look-up table entries
    for role_user in RolesUser.find_all_by_role_id(params[:id])
      role_user.destroy
    end
    flash[:notice] = t('flash.role_deleted')
    redirect_to roles_path
  end
end
