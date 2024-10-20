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
    @action_name = action_name #同一コントローラー内に二つのeditがあるときのため
    @partner = Partner.find(params[:partner_id])
    if request.get? then
      if params[:user_id]
        @item = User.find(params[:user_id])
        if params[:alert]
          @alert = true
          request.env["HTTP_REFERER"] = @referer
        end
      elsif
        @item = User.new
      end
    elsif request.post? then
      @item = User.new(user_params)
      @alert = true
      if @item.valid?
        @item.save!
        redirect_to action: :edit, user_id: @item.id, alert: true
        return
      end
    elsif request.patch? then
      @item = User.find(params[:user_id])
      @item.update(user_params)
    end

    @form_name = "管理者編集"
    #columnのidはダミー、indexのフリーはダミー
    @form_create = []
    @form_create.push({index:"本部権限", column:"admin_flg", required:false, type:"check_box", option:[["あり",0]]})
    @form_create.push({index:"パートナー名", column:"partner_id", required:true, type:"hidden_field", display:@partner.name, hidden_value:@partner.id})
    @form_create.push({index:"名前", column:"name", required:true, type:"text_field"})
    @form_create.push({index:"メールアドレス", column:"mail", required:true, type:"text_field"})
    @form_create.push({index:"パスワード", column:"password", required:true, type:"password"})
    @form_create.push({index:"パスワード", column:"password_confirmation", required:true, type:"password"})

    respond_to do |format|
      format.html {
        render "admin_partial/edit/edit"
      }
      format.js {
        render "admin_partial/edit/edit_error"
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
