class PartnersController < ApplicationController
  layout 'for_admin'
  before_action :login_required
  # before_action :auth_verification

  def index
    @partners = Partner.all

    #公開ボタン用
    @confirm = "【確認】サイト全体が非公開になります。よろしいですか？"

    @setting = []
    #setting.push([項目名,PC表示順,幅,over_admin,sp_menu])
    #下記の並び順はスマホでの順番になる
    @setting.push(["企業名",1,15,"","true"])
    @setting.push(["ID",0,3,"",""])
    @setting.push(["公開",2,7,"",""])
    @setting.push(["登録カテゴリー",3,15,"",""])
    @setting.push(["公開コンテンツ",4,10,"",""])
    @setting.push(["管理者",5,7,"",""])
    @setting.push(["ポスト",6,7,"",""])
    @setting.push(["プレビュー",7,7,"",""])
    @setting.push(["編集",8,7,"",""])
    @setting.push(["削除",9,7,"",""])

    @data = []
    @data.push(@setting)

    @partners.each do |item|
      @row = []
      #row.push([表示内容,表示形式,色,リンク先,ウィンドウ])
      @row.push([item.name,"text","","",""])
      @row.push([item.id,"text","","",""])
      @row.push(["公開",item.disclose_flg,partner_publish_path(publish_id: item.id)]) #公開は予約対応で、["公開",disclose_flg,path]
      @row.push([item.category.gsub("[", "").gsub("]", "").gsub("\"", ""),"text","","",""])
      @row.push([item.topic_categories.where(disclose_flg: "1").size.to_s + "カテゴリー","btn","btn-outline-primary",topic_category_index_path(partner_id: item.id),""])
      @row.push([item.users.size.to_s + "人","btn","btn-outline-primary",user_index_path(partner_id: item.id),""])
      @row.push([item.posts.where(disclose_flg: "1").size.to_s + "件","btn","btn-outline-primary",post_index_path(partner_id: item.id),""])
      @row.push(["プレビュー","btn","btn-outline-primary",partner_top_path(partner_url: item.url),"blank"])
      @row.push(["編集","btn","btn-outline-primary",partner_edit_path(partner_id: item.id),""])
      @row.push(["削除","btn","btn-outline-secondary",partner_destroy_path(destroy_id: item.id),"remote_destroy"])
      @data.push(@row)
    end
  end

  def edit
    if request.get? then
      if params[:partner_id]
        @partner = Partner.find(params[:partner_id])
        if params[:alert]
          @alert = true
          request.env["HTTP_REFERER"] = partner_index_path
        end
      else
        @partner = Partner.new
      end
    elsif request.post? then
      @partner = Partner.new(partner_params)
      if @partner.valid?
        @partner.save!

        redirect_to action: :edit, partner_id: @partner.id, alert: true
        return
      else
        @partner.errors.add(:base, '画像を選択していた場合、再度添付してください。')
      end
    elsif request.patch? then
      ActiveStorage::Blob.unattached.find_each(&:purge)
      @partner_new = Partner.new(partner_params)
      @partner = Partner.find(params[:partner_id])
      @partner_old = Partner.find(params[:partner_id])

      if !@partner.update(partner_params)
        @partner.errors.add(:base, '画像を選択していた場合、再度添付してください。')
        #validationエラー時に少なくとも昔の画像が見えるようにする
        patch_image_fallback(@partner_new.main_image, @partner_old.main_image, @partner.main_image)
        patch_image_fallback(@partner_new.thumbnail, @partner_old.thumbnail, @partner.thumbnail)
      end
    end

    respond_to do |format|
      format.html
      format.js {
        @item = @partner
        @model_name = "partner"
        @thumbnail = true
        @thumbnail_del_id = ""
        @main_image = true
        @main_image_del_id = ""
        @alert = true
        render "admin_partial/edit/edit_error"
      }
    end
  end

  def destroy
    @destroy_item = Partner.find(params[:destroy_id])
    destroy_item(@destroy_item, @destroy_item.name)
  end

  def publish
    @confirm = "【確認】サイト全体が非公開になります。よろしいですか？"
    @publish_item = Partner.find(params[:publish_id])
    @publish_path = partner_publish_path(publish_id: @publish_item.id)

    publish_item(@confirm, @publish_item, @publish_path)
  end

  private

  def partner_params
    params.require(:partner).permit(
      :name,
      :map_url, :url, :privacy_policy, :mail,
      :label, :main_image_position, :catch_copy, :catch_copy_color, :catch_copy_position, :main_color,
      :contact_mail, :contact_tel, :contact_line, :contact_x, :contact_fb, :contact_linkedin, :contact_insta, :contact_mail,
      :info1_item, :info1_content,
      :info2_item, :info2_content,
      :info3_item, :info3_content,
      :info4_item, :info4_content,
      :info5_item, :info5_content,
      :info6_item, :info6_content,
      :info7_item, :info7_content,
      :info8_item, :info8_content,
      :info9_item, :info9_content,
      :info10_item, :info10_content,
      :disclose_flg, 
      :main_image, :thumbnail,
      category:[]
    )
  end

end
