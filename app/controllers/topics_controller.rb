class TopicsController < ApplicationController
  layout 'for_admin'
  before_action :login_required
  # before_action :auth_verification

  def index_category
    @partner = Partner.find(params[:partner_id])
    @topic_categories = TopicCategory.where(partner_id: params[:partner_id]).order('display_order ASC')

    @setting = []
    #setting.push([項目名,PC表示順,幅,over_admin,sp_menu])
    #下記の並び順はスマホでの順番になる
    @setting.push(["カテゴリー名",1,10,"","true"])
    @setting.push(["ID",0,3,"",""])
    @setting.push(["公開",2,5,"",""])
    @setting.push(["掲載順",3,3,"",""])
    @setting.push(["メニューバー表示",4,10,"",""])
    @setting.push(["コンテンツタイプ",5,10,"",""])
    @setting.push(["トップページ表示形式",6,10,"",""])
    @setting.push(["公開コンテンツ",7,10,"",""])
    @setting.push(["編集",8,5,"",""])
    @setting.push(["削除",9,5,"",""])

    @data = []
    @data.push(@setting)

    @topic_categories.each do |item|
      @row = []
      #row.push([表示内容,表示形式,色,リンク先,ウィンドウ])
      @row.push([item.name,"text","","",""])
      @row.push([item.id,"text","","",""])
      @row.push(["公開",item.disclose_flg,topic_category_publish_path(publish_id: item.id)]) #公開は予約対応で、["公開",disclose_flg,path]
      @row.push([item.display_order,"text","","",""])
      @row.push([item.menu_name,"text","","",""])
      @row.push([item.content_type,"text","","",""])
      @row.push([item.display_style,"text","","",""])
      if item.content_type == "求人"
        @row.push([@partner.jobs.where(disclose_flg: "1").size.to_s + "件","btn","btn-outline-primary",job_index_path(partner_id: @partner.id),""])
      else
        @row.push([item.topics.where(disclose_flg: "1").size.to_s + "件","btn","btn-outline-primary",topic_index_path(partner_id: @partner.id,topic_category_id: item.id),""])
      end
      @row.push(["編集","btn","btn-outline-primary",topic_category_edit_path(partner_id: @partner.id, topic_category_id: item.id),""])
      @row.push(["削除","btn","btn-outline-secondary",topic_category_destroy_path(destroy_id: item.id),"remote_destroy"])
      @data.push(@row)
    end
  end

  def edit_category
    @partner = Partner.find(params[:partner_id])

    if request.get? then
      if params[:topic_category_id]
        @topic_category = TopicCategory.find(params[:topic_category_id])
        if params[:alert]
          @alert = true
          request.env["HTTP_REFERER"] = topic_category_index_path
        end
      elsif
        @topic_category = TopicCategory.new
      end
    elsif request.post? then
      @topic_category = TopicCategory.new(topic_category_params)
      if @topic_category.valid?
        @topic_category.save!

        redirect_to action: :edit_category, topic_category_id: @topic_category.id, alert: true
        return
      else
        @topic_category.errors.add(:base, '画像を選択していた場合、再度添付してください。')
      end
    elsif request.patch? then
      ActiveStorage::Blob.unattached.find_each(&:purge)
      @topic_category_new = TopicCategory.new(topic_category_params)
      @topic_category = TopicCategory.find(params[:topic_category_id])
      @topic_category_old = TopicCategory.find(params[:topic_category_id])

      if !@topic_category.update(topic_category_params)
        @topic_category.errors.add(:base, '画像を選択していた場合、再度添付してください。')
        #validationエラー時に少なくとも昔の画像が見えるようにする
        patch_image_fallback(@topic_category_new.thumbnail, @topic_category_old.thumbnail, @topic_category.thumbnail)
      end
    end
    respond_to do |format|
      format.html
      format.js {
        @item = @topic_category
        @alert = true
        @thumbnail = true
        @thumbnail_del_id = ""
        render "admin_partial/edit/edit_error"
      }
    end
  end

  def destroy_category
    @destroy_item = TopicCategory.find(params[:destroy_id])
    destroy_item(@destroy_item, @destroy_item.name)
  end

  def publish_category
    @confirm = ""
    @publish_item = TopicCategory.find(params[:publish_id])
    @publish_path = topic_category_publish_path(publish_id: @publish_item.id)

    publish_item(@confirm, @publish_item, @publish_path)
  end

  def index
    @partner = Partner.find(params[:partner_id])
    @topic_category = TopicCategory.find(params[:topic_category_id])
    @topics = Topic.where(topic_category_id: @topic_category.id).order('display_order ASC')

    @setting = []
    #setting.push([項目名,PC表示順,幅,over_admin,sp_menu])
    #下記の並び順はスマホでの順番になる
    @setting.push(["タイトル",1,15,"","true"])
    @setting.push(["ID",0,3,"",""])
    @setting.push(["公開",2,7,"",""])
    @setting.push(["掲載順",3,7,"",""])
    @setting.push(["プレビュー",4,7,"",""])
    @setting.push(["登録日",5,7,"",""])
    @setting.push(["更新日",6,7,"",""])
    @setting.push(["編集",7,7,"",""])
    @setting.push(["削除",8,7,"",""])

    @data = []
    @data.push(@setting)

    @topics.each do |item|
      @row = []
      #row.push([表示内容,表示形式,色,リンク先,ウィンドウ])
      @row.push([item.title,"text","","",""])
      @row.push([item.id,"text","","",""])
      @row.push(["公開",item.disclose_flg,topic_publish_path(publish_id: item.id)]) #公開は予約対応で、["公開",disclose_flg,path]
      @row.push([item.display_order,"text","","",""])
      @row.push(["プレビュー","btn","btn-outline-primary",topic_path(partner_url: @partner.url, topic_category_id: item.topic_category_id, topic_id: item.id),"blank"])
      @row.push([l(item.created_at,format: :date),"text","","",""])
      @row.push([l(item.updated_at,format: :date),"text","","",""])
      @row.push(["編集","btn","btn-outline-primary",topic_edit_path(topic_id: item.id),""])
      @row.push(["削除","btn","btn-outline-secondary",topic_destroy_path(destroy_id: item.id),"remote_destroy"])
      @data.push(@row)
    end

  end

  def edit
    @partner = Partner.find(params[:partner_id])
    @topic_category = TopicCategory.find(params[:topic_category_id])

    if request.get? then
      if params[:topic_id]
        @topic = Topic.find(params[:topic_id])
        if params[:alert]
          @alert = true
          request.env["HTTP_REFERER"] = topic_index_path
        end
      elsif
        @topic = Topic.new
      end
    elsif request.post? then
      @topic = Topic.new(topic_params)
      if @topic.valid?
        @topic.save!

        redirect_to action: :edit, topic_id: @topic.id, alert: true
        return
      else
        @topic.errors.add(:base, '画像を選択していた場合、再度添付してください。')
      end
    elsif request.patch? then
      ActiveStorage::Blob.unattached.find_each(&:purge)
      @topic_new = Topic.new(topic_params)
      @topic = Topic.find(params[:topic_id])
      @topic_old = Topic.find(params[:topic_id])

      #画像の削除
      patch_image_delete(@topic.content_image1, params[:topic][:content_image1_del_id])
      patch_image_delete(@topic.content_image2, params[:topic][:content_image2_del_id])
      patch_image_delete(@topic.content_image3, params[:topic][:content_image3_del_id])
      patch_image_delete(@topic.content_image4, params[:topic][:content_image4_del_id])
      patch_image_delete(@topic.content_image5, params[:topic][:content_image5_del_id])
      patch_image_delete(@topic.content_image6, params[:topic][:content_image6_del_id])
      patch_image_delete(@topic.content_image7, params[:topic][:content_image7_del_id])
      patch_image_delete(@topic.content_image8, params[:topic][:content_image8_del_id])

      if !@topic.update(topic_params)
        @topic.errors.add(:base, '画像を選択していた場合、再度添付してください。')

        #validationエラー時に少なくとも昔の画像が見えるようにする
        patch_image_fallback(@topic_new.main_image, @topic_old.main_image, @topic.main_image)
        patch_image_fallback(@topic_new.content_image1, @topic_old.content_image1, @topic.content_image1)
        patch_image_fallback(@topic_new.content_image2, @topic_old.content_image2, @topic.content_image2)
        patch_image_fallback(@topic_new.content_image3, @topic_old.content_image3, @topic.content_image3)
        patch_image_fallback(@topic_new.content_image4, @topic_old.content_image4, @topic.content_image4)
        patch_image_fallback(@topic_new.content_image5, @topic_old.content_image5, @topic.content_image5)
        patch_image_fallback(@topic_new.content_image6, @topic_old.content_image6, @topic.content_image6)
        patch_image_fallback(@topic_new.content_image7, @topic_old.content_image7, @topic.content_image7)
        patch_image_fallback(@topic_new.content_image8, @topic_old.content_image8, @topic.content_image8)
      end
    end

    if @topic.id.present?
      # プレビュー用のパス
      @path = topic_path(partner_url: @partner.url, topic_category_id: @topic_category.id, topic_id: @topic.id)
    end

    respond_to do |format|
      format.html
      format.js {
        @item = @topic
        @model_name = "topic"
        @alert = true
        @rich_content = true
        @main_image = true
        @main_image_del_id = ""
        render "admin_partial/edit/edit_error"
      }
    end
  end

  def destroy
    @destroy_item = Topic.find(params[:destroy_id])
    destroy_item(@destroy_item, @destroy_item.title)
  end

  def publish
    @confirm = ""
    @publish_item = Topic.find(params[:publish_id])
    @publish_path = topic_publish_path(publish_id: @publish_item.id)

    publish_item(@confirm, @publish_item, @publish_path)
  end

  private

  def topic_category_params
    params.require(:topic_category).permit(
      :partner_id, :name, :menu_name, :subscript, :description,
      :display_order, :content_type, :display_style, :movie_url,
      :disclose_flg, :thumbnail
    )
  end

  def topic_params
    params.require(:topic).permit(
      :topic_category_id, :title, :description, :index_type,
      :movie_url,
      :item1_label, :item1_content, :content_image1, :item1_position, :item1_image_alt, :item1_movie_url,
      :item2_label, :item2_content, :content_image2, :item2_position, :item2_image_alt, :item2_movie_url,
      :item3_label, :item3_content, :content_image3, :item3_position, :item3_image_alt, :item3_movie_url,
      :item4_label, :item4_content, :content_image4, :item4_position, :item4_image_alt, :item4_movie_url,
      :item5_label, :item5_content, :content_image5, :item5_position, :item5_image_alt, :item5_movie_url,
      :item6_label, :item6_content, :content_image6, :item6_position, :item6_image_alt, :item6_movie_url,
      :item7_label, :item7_content, :content_image7, :item7_position, :item7_image_alt, :item7_movie_url,
      :item8_label, :item8_content, :content_image8, :item8_position, :item8_image_alt, :item8_movie_url,
      :display_order, :disclose_flg,
      :main_image
    )
  end
end
