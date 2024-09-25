class UsersController < ApplicationController
  layout 'for_admin'
  before_action :login_required

  def index
    @users = User.where(partner_id: params[:partner_id]).order('created_at DESC')

    @setting = []
    #setting.push([項目名,PC表示順,幅,over_admin,sp_menu])
    #下記の並び順はスマホでの順番になる
    @setting.push(["名前",1,15,"","true"])
    @setting.push(["ID",0,3,"",""])
    @setting.push(["メールアドレス",2,15,"",""])
    @setting.push(["編集",3,7,"",""])
    @setting.push(["削除",4,7,"",""])

    @data = []
    @data.push(@setting)

    @users.each do |item|
      @row = []
      #row.push([表示内容,表示形式,色,リンク先,ウィンドウ])
      @row.push([item.name,"text","","",""])
      @row.push([item.id,"text","","",""])
      @row.push([item.mail,"text","","",""])
      @row.push(["編集","btn","btn-outline-primary",user_edit_path(user_id: item.id),""])
      @row.push(["削除","btn","btn-outline-secondary",user_destroy_path(destroy_id: item.id),"remote_destroy"])
      @data.push(@row)
    end
  end

  def edit
    @partner = Partner.find(params[:partner_id])
    if request.get? then
      if params[:user_id]
        @user = User.find(params[:user_id])
        if params[:alert]
          @alert = true
          request.env["HTTP_REFERER"] = @referer
        end
      elsif
        @user = User.new
      end
    elsif request.post? then
      @user = User.new(user_params)
      if @user.valid?
        @user.save!
        redirect_to action: :edit, user_id: @user.id, alert: true
        return
      end
    elsif request.patch? then
      @user = User.find(params[:user_id])
      @user.update(user_params)
    end
    respond_to do |format|
      format.html
      format.js {
        @item = @user
        @alert = true
        render "admin_partial/edit_error/edit_error"
      }
    end
  end

  def destroy
    @destroy_item = User.find(params[:destroy_id])
    destroy_item(@destroy_item, @destroy_item.name)
  end

  private

  def user_params
    params.require(:user).permit(
      :partner_id, :admin_flg,
      :name, :mail, :password, :password_confirmation,
      )
  end
end
