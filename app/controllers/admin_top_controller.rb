class AdminTopController < ApplicationController
  layout 'for_admin'
  # before_action :login_required
  # before_action :auth_verification

  def index
    if current_user.admin_flg?
      redirect_to controller: :partners, action: :index
    # else
    #   redirect_to controller: :agencies, action: :index, agency_id: current_user.agency_id
    end
  end

end
