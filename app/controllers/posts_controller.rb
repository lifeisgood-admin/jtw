class PostsController < ApplicationController
  layout 'for_admin'
  before_action :login_required
  # before_action :auth_verification

  def index
    @partner = Partner.find(params[:partner_id])
    @posts = Post.where(partner_id: params[:partner_id])

    @setting = []
    #setting.push([項目名,PC表示順,幅,over_admin,sp_menu])
    #下記の並び順はスマホでの順番になる
    @setting.push(["タイトル",1,15,"","true"])
    @setting.push(["ID",0,3,"",""])
    @setting.push(["公開",2,7,"",""])
    @setting.push(["登録カテゴリー",3,15,"",""])
    @setting.push(["プレビュー",4,7,"",""])
    @setting.push(["登録日",5,7,"",""])
    @setting.push(["編集",6,7,"",""])
    @setting.push(["削除",7,7,"",""])

    @data = []
    @data.push(@setting)

    @posts.each do |item|
      @row = []
      #row.push([表示内容,表示形式,色,リンク先,ウィンドウ])
      @row.push([item.title,"text","","",""])
      @row.push([item.id,"text","","",""])
      @row.push(["公開",item.disclose_flg,post_publish_path(publish_id: item.id)]) #公開は予約対応で、["公開",disclose_flg,path]
      @row.push([item.category,"text","","",""])
      @row.push(["プレビュー","btn","btn-outline-primary",post_path(partner_url: @partner.url, post_id: item.id),"blank"])
      @row.push([l(item.created_at,format: :date),"text","","",""])
      @row.push(["編集","btn","btn-outline-primary",post_edit_path(post_id: item.id),""])
      @row.push(["削除","btn","btn-outline-secondary",post_destroy_path(destroy_id: item.id),"remote_destroy"])
      @data.push(@row)
    end

  end

  def edit
    @partner = Partner.find(params[:partner_id])

    if request.get? then
      if params[:post_id]
        @post = Post.find(params[:post_id])
        if params[:alert]
          @alert = true
          request.env["HTTP_REFERER"] = post_index_path
        end
      elsif
        @post = Post.new
      end
    elsif request.post? then
      @post = Post.new(post_params)
      if @post.valid?
        @post.save!

        redirect_to action: :edit, post_id: @post.id, alert: true
        return
      else
        @post.errors.add(:base, '画像を選択していた場合、再度添付してください。')
      end
    elsif request.patch? then
      ActiveStorage::Blob.unattached.find_each(&:purge)
      @post_new = Post.new(post_params)
      @post = Post.find(params[:post_id])
      @post_old = Post.find(params[:post_id])

      #画像の削除
      patch_image_delete(@post.content_image1, params[:post][:content_image1_del_id])
      patch_image_delete(@post.content_image2, params[:post][:content_image2_del_id])
      patch_image_delete(@post.content_image3, params[:post][:content_image3_del_id])
      patch_image_delete(@post.content_image4, params[:post][:content_image4_del_id])
      patch_image_delete(@post.content_image5, params[:post][:content_image5_del_id])
      patch_image_delete(@post.content_image6, params[:post][:content_image6_del_id])
      patch_image_delete(@post.content_image7, params[:post][:content_image7_del_id])
      patch_image_delete(@post.content_image8, params[:post][:content_image8_del_id])

      if !@post.update(post_params)
        @post.errors.add(:base, '画像を選択していた場合、再度添付してください。')

        #validationエラー時に少なくとも昔の画像が見えるようにする
        patch_image_fallback(@post_new.main_image, @post_old.main_image, @post.main_image)
        patch_image_fallback(@post_new.content_image1, @post_old.content_image1, @post.content_image1)
        patch_image_fallback(@post_new.content_image2, @post_old.content_image2, @post.content_image2)
        patch_image_fallback(@post_new.content_image3, @post_old.content_image3, @post.content_image3)
        patch_image_fallback(@post_new.content_image4, @post_old.content_image4, @post.content_image4)
        patch_image_fallback(@post_new.content_image5, @post_old.content_image5, @post.content_image5)
        patch_image_fallback(@post_new.content_image6, @post_old.content_image6, @post.content_image6)
        patch_image_fallback(@post_new.content_image7, @post_old.content_image7, @post.content_image7)
        patch_image_fallback(@post_new.content_image8, @post_old.content_image8, @post.content_image8)
      end
    end

    if @post.id.present?
      # プレビュー用のパス
      @path = post_path(partner_url: @partner.url, post_id: @post.id)
    end

    respond_to do |format|
      format.html
      format.js {
        @item = @post
        @model_name = "post"
        @alert = true
        @rich_content = true
        @main_image = true
        @main_image_del_id = ""
        render "admin_partial/edit_error/edit_error"
      }
    end
  end

  def destroy
    @destroy_item = Post.find(params[:destroy_id])
    destroy_item(@destroy_item, @destroy_item.title)
  end

  def publish
    @confirm = ""
    @publish_item = Post.find(params[:publish_id])
    @publish_path = post_publish_path(publish_id: @publish_item.id)

    publish_item(@confirm, @publish_item, @publish_path)
  end

  private

  def post_params
    params.require(:post).permit(
      :partner_id,
      :category,
      :title, :description, :index_type,
      :movie_url,
      :item1_label, :item1_content, :content_image1, :item1_position, :item1_image_alt, :item1_movie_url,
      :item2_label, :item2_content, :content_image2, :item2_position, :item2_image_alt, :item2_movie_url,
      :item3_label, :item3_content, :content_image3, :item3_position, :item3_image_alt, :item3_movie_url,
      :item4_label, :item4_content, :content_image4, :item4_position, :item4_image_alt, :item4_movie_url,
      :item5_label, :item5_content, :content_image5, :item5_position, :item5_image_alt, :item5_movie_url,
      :item6_label, :item6_content, :content_image6, :item6_position, :item6_image_alt, :item6_movie_url,
      :item7_label, :item7_content, :content_image7, :item7_position, :item7_image_alt, :item7_movie_url,
      :item8_label, :item8_content, :content_image8, :item8_position, :item8_image_alt, :item8_movie_url,
      :disclose_flg,
      :main_image
    )
  end

end
