class UsersController < ApplicationController
  layout 'common'
 
  require_login :role => :admin, :except => [:show, :edit, :update]
  require_login :only => [:show, :edit, :update]

  def index
    @users = User.find(:all, :order => :login)
    # TODO: sort users by role
    # --> difficult if multiple roles per user.
    # perhaps show users multiple times under each role they have!
    #   --> write a helper so this can be optionally reused once implemented! 
    #   --> or perhaps better write an additional roles#index!
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      set_locale(@user.language)
      flash[:notice] = t('flash.user_created')
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end

  # If user edits his account and logs out, he will be directed to this action on his next login,
  # instead of edit action, REST seems to suck here. So lets redirect him manually.
  def show
    redirect_to :action => 'edit', :id => params[:id]
  end

  
  def edit
    # users can only edit their own page
    @user = current_user

    # admins can edit all users
    if current_user.has_role?(:admin)
      @user = User.find(params[:id]) if params[:id]
    end
  end
  
  
  def update
    # users can only edit their own page
    @user = current_user

    # useradmins and higher can edit all users
    if current_user.has_role?(:admin)
      @user = User.find(params[:id]) if params[:id]
    end

    params[:user][:login] = @user.login  # login name is readonly
    
    if @user.update_attributes(params[:user])
      set_locale(@user.language)
      flash.now[:notice] = t('flash.user_updated')
      # if admin and editing another user, then go back to user index 
    end
    
    render :action => 'edit'
  end


  def delete
    @user = User.find(params[:id])
    login = @user.login
    @user.destroy
    
    flash[:notice] = t('flash.user_deleted', :login => login)
    redirect_to users_path
  end

  
  def grant_role
    user = User.find_by_id(params[:id])
    # ensure only system admins grant system admin roles
    unless Role.find_by_id(params[:role_id]).title == 'system_admin' and not current_user.has_role?('system_admin')
      user.add_roles(params[:role_id])
    end
    render_roles_partial user
  end

  def revoke_role
    user = User.find_by_id(params[:id])
    user.remove_roles(params[:role_id])
    render_roles_partial user
  end

  def render_roles_partial user
    render :partial => 'pallets/roles', :locals => { :id => user.id,
                                                     :current_roles => user.role_ids,
                                                     :show_admin_roles  => (params[:show_admin_roles]  == 'true'),
                                                     :show_pallet_roles => (params[:show_pallet_roles] == 'true') }
  end
end
