class SessionLogsController < ApplicationController
  #before_filter :login_required
  #access_control :DEFAULT => 'admin'
  require_login :role => 'admin'

  layout 'common'

  def index
    conditions = nil
    if params[:filter_start] and params[:filter_end]
      filter_start = Time.parse(params[:filter_start])
      filter_end   = Time.parse(params[:filter_end])
      conditions = ["(logged_in_at  >= ? AND logged_in_at  <= ?) OR " +
                    "(logged_out_at >= ? AND logged_out_at <= ?)", 
                    filter_start, filter_end,
                    filter_start, filter_end]
    end
    
    page = params[:page] || 1
    per_page = params[:per_page] || 50

    
    @session_logs = SessionLog.paginate(:all, :page => page, :per_page => per_page, :conditions => conditions, :order => 'logged_in_at DESC')
    
  end
  
end
