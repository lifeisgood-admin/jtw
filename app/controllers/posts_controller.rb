class PostsController < ApplicationController
  layout 'for_admin'
  before_action :login_required
  before_action :admin_partner_info_create, only: [:index]
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
    @action_name = action_name #同一コントローラー内に二つのeditがあるときのため
    @partner = Partner.find(params[:partner_id])

    if request.get? then
      if params[:post_id]
        @item = Post.find(params[:post_id])
        if params[:alert]
          @alert = true
          request.env["HTTP_REFERER"] = post_index_path
        end
      elsif
        @item = Post.new
      end
    elsif request.post? then
      @item = Post.new(post_params)
      @alert = true
      if @item.valid?
        @item.save!

        redirect_to action: :edit, post_id: @item.id, alert: true
        return
      else
        @item.errors.add(:base, '画像を選択していた場合、再度添付してください。')
      end
    elsif request.patch? then
      ActiveStorage::Blob.unattached.find_each(&:purge)
      @item_new = Post.new(post_params)
      @item = Post.find(params[:post_id])
      @item_old = Post.find(params[:post_id])

      #画像の削除
      patch_image_delete(@item.thumbnail, params[:post][:thumbnail_del_id])
      patch_image_delete(@item.content_image1, params[:post][:content_image1_del_id])
      patch_image_delete(@item.content_image2, params[:post][:content_image2_del_id])
      patch_image_delete(@item.content_image3, params[:post][:content_image3_del_id])
      patch_image_delete(@item.content_image4, params[:post][:content_image4_del_id])
      patch_image_delete(@item.content_image5, params[:post][:content_image5_del_id])
      patch_image_delete(@item.content_image6, params[:post][:content_image6_del_id])
      patch_image_delete(@item.content_image7, params[:post][:content_image7_del_id])
      patch_image_delete(@item.content_image8, params[:post][:content_image8_del_id])

      if !@item.update(post_params)
        @item.errors.add(:base, '画像を選択していた場合、再度添付してください。')

        #validationエラー時に少なくとも昔の画像が見えるようにする
        patch_image_fallback(@item_new.main_image, @item_old.main_image, @item.main_image)
        patch_image_fallback(@item_new.thumbnail, @item_old.thumbnail, @item.thumbnail)
        patch_image_fallback(@item_new.content_image1, @item_old.content_image1, @item.content_image1)
        patch_image_fallback(@item_new.content_image2, @item_old.content_image2, @item.content_image2)
        patch_image_fallback(@item_new.content_image3, @item_old.content_image3, @item.content_image3)
        patch_image_fallback(@item_new.content_image4, @item_old.content_image4, @item.content_image4)
        patch_image_fallback(@item_new.content_image5, @item_old.content_image5, @item.content_image5)
        patch_image_fallback(@item_new.content_image6, @item_old.content_image6, @item.content_image6)
        patch_image_fallback(@item_new.content_image7, @item_old.content_image7, @item.content_image7)
        patch_image_fallback(@item_new.content_image8, @item_old.content_image8, @item.content_image8)
      end
    end

    if @item.id.present?
      # プレビュー用のパス
      @path = post_path(partner_url: @partner.url, post_id: @item.id)
    end

    @form_name = "ポスト編集"
    #columnのidはダミー、indexのフリーはダミー
    @form_create = []
    @form_create.push({index:"パートナー名", column:"partner_id", required:true, type:"hidden_field", display:@partner.name, hidden_value:@partner.id})
    @form_create.push({index:"登録カテゴリー", column:"category", required:true, type:"radio_button", option:[["事業パートナー募集","事業パートナー募集"],["福利厚生サービス紹介","福利厚生サービス紹介"]]})
    @form_create.push({index:"公開設定", column:"disclose_flg", required:true, type:"select", option:[["非公開",0],["公開",1]]})

    @form_create.push({group:"【画像】"})
    @form_create.push({index:"サムネイル", column:"thumbnail", required:false, type:"image", del_id:@thumbnail_del_id = "thumbnail_del_id", tt:["添付が無い場合は、パートナー情報に添付されたサムネイルが表示されます。"]}) #画像はrequiredではなくdel_idの有無で必須か判断している
    @form_create.push({index:"メインビジュアル", column:"main_image", required:true, type:"image", del_id:@main_image_del_id = ""})

    @form_create.push({group:"【動画】"})
    @text = '<a href="https://support.google.com/youtube/answer/171780?hl=ja" target="_blank" rel="noopener noreferrer"><span class="min-font"><b>取得方法はこちらから</b></span></a><br><span class="min-font">1.説明ページの1~4を実行<br></span><span class="min-font">2.こちらの欄に取得したHTMLコードを入力して保存<br></span>'
    @form_create.push({index:"Youtube URL", column:"movie_url", required:false, type:"text_area", height:"6", ind_desc:[@text]})

    @form_create.push({group:"【基本情報】"})
    @form_create.push({index:"タイトル", column:"title", required:true, type:"text_field"})
    @form_create.push({index:"説明文", column:"description", required:true, type:"text_area", height:"3"})

    @form_create.push({group:"【コンテンツ設定】"})
    @form_create.push({index:"段落形式", column:"index_type", required:true, type:"radio_button", option:[["数字","数字"],["QA","QA"],["なし","なし"]]})

    @form_create.push({group:"【コンテンツ１】"})
    @form_create.push({index:"ラベル", column:"item1_label", required:false, type:"text_area", height:""})
    @form_create.push({index:"本文", column:"item1_content", required:false, type:"text_area", height:""})
    @form_create.push({index:"コンテンツ配置", column:"item1_position", required:false, type:"select", option:[["選択してください",""],["左","left"],["上","top"],["右","right"],["下","bottom"]], tt:["未選択の場合は文章の右側に配置されます。<br>動画と画像が両方存在する場合は、動画が優先されます。"]})
    @text = '<a href="https://support.google.com/youtube/answer/171780?hl=ja" target="_blank" rel="noopener noreferrer"><span class="min-font"><b>取得方法はこちらから</b></span></a><br><span class="min-font">1.説明ページの1~4を実行<br></span><span class="min-font">2.こちらの欄に取得したHTMLコードを入力して保存<br></span>'
    @form_create.push({index:"動画（YouTubeURL）", column:"item1_movie_url", required:false, type:"text_area", height:"3", ind_desc:[@text]})
    @form_create.push({index:"画像説明（altタグ）", column:"item1_image_alt", required:false, type:"text_field", tt:["検索エンジンに画像の内容を説明するために入力します。"]})
    @form_create.push({index:"添付画像１", column:"content_image1", required:false, type:"image", del_id:"content_image1_del_id"})

    @form_create.push({group:"【コンテンツ２】"})
    @form_create.push({index:"ラベル", column:"item2_label", required:false, type:"text_area", height:""})
    @form_create.push({index:"本文", column:"item2_content", required:false, type:"text_area", height:""})
    @form_create.push({index:"コンテンツ配置", column:"item2_position", required:false, type:"select", option:[["選択してください",""],["左","left"],["上","top"],["右","right"],["下","bottom"]], tt:["未選択の場合は文章の右側に配置されます。<br>動画と画像が両方存在する場合は、動画が優先されます。"]})
    @text = '<a href="https://support.google.com/youtube/answer/171780?hl=ja" target="_blank" rel="noopener noreferrer"><span class="min-font"><b>取得方法はこちらから</b></span></a><br><span class="min-font">1.説明ページの1~4を実行<br></span><span class="min-font">2.こちらの欄に取得したHTMLコードを入力して保存<br></span>'
    @form_create.push({index:"動画（YouTubeURL）", column:"item2_movie_url", required:false, type:"text_area", height:"3", ind_desc:[@text]})
    @form_create.push({index:"画像説明（altタグ）", column:"item2_image_alt", required:false, type:"text_field", tt:["検索エンジンに画像の内容を説明するために入力します。"]})
    @form_create.push({index:"添付画像２", column:"content_image2", required:false, type:"image", del_id:"content_image2_del_id"})

    @form_create.push({group:"【コンテンツ３】"})
    @form_create.push({index:"ラベル", column:"item3_label", required:false, type:"text_area", height:""})
    @form_create.push({index:"本文", column:"item3_content", required:false, type:"text_area", height:""})
    @form_create.push({index:"コンテンツ配置", column:"item3_position", required:false, type:"select", option:[["選択してください",""],["左","left"],["上","top"],["右","right"],["下","bottom"]], tt:["未選択の場合は文章の右側に配置されます。<br>動画と画像が両方存在する場合は、動画が優先されます。"]})
    @text = '<a href="https://support.google.com/youtube/answer/171780?hl=ja" target="_blank" rel="noopener noreferrer"><span class="min-font"><b>取得方法はこちらから</b></span></a><br><span class="min-font">1.説明ページの1~4を実行<br></span><span class="min-font">2.こちらの欄に取得したHTMLコードを入力して保存<br></span>'
    @form_create.push({index:"動画（YouTubeURL）", column:"item3_movie_url", required:false, type:"text_area", height:"3", ind_desc:[@text]})
    @form_create.push({index:"画像説明（altタグ）", column:"item3_image_alt", required:false, type:"text_field", tt:["検索エンジンに画像の内容を説明するために入力します。"]})
    @form_create.push({index:"添付画像３", column:"content_image3", required:false, type:"image", del_id:"content_image3_del_id"})

    @form_create.push({group:"【コンテンツ４】"})
    @form_create.push({index:"ラベル", column:"item4_label", required:false, type:"text_area", height:""})
    @form_create.push({index:"本文", column:"item4_content", required:false, type:"text_area", height:""})
    @form_create.push({index:"コンテンツ配置", column:"item4_position", required:false, type:"select", option:[["選択してください",""],["左","left"],["上","top"],["右","right"],["下","bottom"]], tt:["未選択の場合は文章の右側に配置されます。<br>動画と画像が両方存在する場合は、動画が優先されます。"]})
    @text = '<a href="https://support.google.com/youtube/answer/171780?hl=ja" target="_blank" rel="noopener noreferrer"><span class="min-font"><b>取得方法はこちらから</b></span></a><br><span class="min-font">1.説明ページの1~4を実行<br></span><span class="min-font">2.こちらの欄に取得したHTMLコードを入力して保存<br></span>'
    @form_create.push({index:"動画（YouTubeURL）", column:"item4_movie_url", required:false, type:"text_area", height:"3", ind_desc:[@text]})
    @form_create.push({index:"画像説明（altタグ）", column:"item4_image_alt", required:false, type:"text_field", tt:["検索エンジンに画像の内容を説明するために入力します。"]})
    @form_create.push({index:"添付画像４", column:"content_image4", required:false, type:"image", del_id:"content_image4_del_id"})

    @form_create.push({group:"【コンテンツ５】"})
    @form_create.push({index:"ラベル", column:"item5_label", required:false, type:"text_area", height:""})
    @form_create.push({index:"本文", column:"item5_content", required:false, type:"text_area", height:""})
    @form_create.push({index:"コンテンツ配置", column:"item5_position", required:false, type:"select", option:[["選択してください",""],["左","left"],["上","top"],["右","right"],["下","bottom"]], tt:["未選択の場合は文章の右側に配置されます。<br>動画と画像が両方存在する場合は、動画が優先されます。"]})
    @text = '<a href="https://support.google.com/youtube/answer/171780?hl=ja" target="_blank" rel="noopener noreferrer"><span class="min-font"><b>取得方法はこちらから</b></span></a><br><span class="min-font">1.説明ページの1~4を実行<br></span><span class="min-font">2.こちらの欄に取得したHTMLコードを入力して保存<br></span>'
    @form_create.push({index:"動画（YouTubeURL）", column:"item5_movie_url", required:false, type:"text_area", height:"3", ind_desc:[@text]})
    @form_create.push({index:"画像説明（altタグ）", column:"item5_image_alt", required:false, type:"text_field", tt:["検索エンジンに画像の内容を説明するために入力します。"]})
    @form_create.push({index:"添付画像５", column:"content_image5", required:false, type:"image", del_id:"content_image5_del_id"})
    
    @form_create.push({group:"【コンテンツ６】"})
    @form_create.push({index:"ラベル", column:"item6_label", required:false, type:"text_area", height:""})
    @form_create.push({index:"本文", column:"item6_content", required:false, type:"text_area", height:""})
    @form_create.push({index:"コンテンツ配置", column:"item6_position", required:false, type:"select", option:[["選択してください",""],["左","left"],["上","top"],["右","right"],["下","bottom"]], tt:["未選択の場合は文章の右側に配置されます。<br>動画と画像が両方存在する場合は、動画が優先されます。"]})
    @text = '<a href="https://support.google.com/youtube/answer/171780?hl=ja" target="_blank" rel="noopener noreferrer"><span class="min-font"><b>取得方法はこちらから</b></span></a><br><span class="min-font">1.説明ページの1~4を実行<br></span><span class="min-font">2.こちらの欄に取得したHTMLコードを入力して保存<br></span>'
    @form_create.push({index:"動画（YouTubeURL）", column:"item6_movie_url", required:false, type:"text_area", height:"3", ind_desc:[@text]})
    @form_create.push({index:"画像説明（altタグ）", column:"item6_image_alt", required:false, type:"text_field", tt:["検索エンジンに画像の内容を説明するために入力します。"]})
    @form_create.push({index:"添付画像６", column:"content_image6", required:false, type:"image", del_id:"content_image6_del_id"})

    @form_create.push({group:"【コンテンツ７】"})
    @form_create.push({index:"ラベル", column:"item7_label", required:false, type:"text_area", height:""})
    @form_create.push({index:"本文", column:"item7_content", required:false, type:"text_area", height:""})
    @form_create.push({index:"コンテンツ配置", column:"item7_position", required:false, type:"select", option:[["選択してください",""],["左","left"],["上","top"],["右","right"],["下","bottom"]], tt:["未選択の場合は文章の右側に配置されます。<br>動画と画像が両方存在する場合は、動画が優先されます。"]})
    @text = '<a href="https://support.google.com/youtube/answer/171780?hl=ja" target="_blank" rel="noopener noreferrer"><span class="min-font"><b>取得方法はこちらから</b></span></a><br><span class="min-font">1.説明ページの1~4を実行<br></span><span class="min-font">2.こちらの欄に取得したHTMLコードを入力して保存<br></span>'
    @form_create.push({index:"動画（YouTubeURL）", column:"item7_movie_url", required:false, type:"text_area", height:"3", ind_desc:[@text]})
    @form_create.push({index:"画像説明（altタグ）", column:"item7_image_alt", required:false, type:"text_field", tt:["検索エンジンに画像の内容を説明するために入力します。"]})
    @form_create.push({index:"添付画像７", column:"content_image7", required:false, type:"image", del_id:"content_image7_del_id"})

    @form_create.push({group:"【コンテンツ８】"})
    @form_create.push({index:"ラベル", column:"item8_label", required:false, type:"text_area", height:""})
    @form_create.push({index:"本文", column:"item8_content", required:false, type:"text_area", height:""})
    @form_create.push({index:"コンテンツ配置", column:"item8_position", required:false, type:"select", option:[["選択してください",""],["左","left"],["上","top"],["右","right"],["下","bottom"]], tt:["未選択の場合は文章の右側に配置されます。<br>動画と画像が両方存在する場合は、動画が優先されます。"]})
    @text = '<a href="https://support.google.com/youtube/answer/171780?hl=ja" target="_blank" rel="noopener noreferrer"><span class="min-font"><b>取得方法はこちらから</b></span></a><br><span class="min-font">1.説明ページの1~4を実行<br></span><span class="min-font">2.こちらの欄に取得したHTMLコードを入力して保存<br></span>'
    @form_create.push({index:"動画（YouTubeURL）", column:"item8_movie_url", required:false, type:"text_area", height:"3", ind_desc:[@text]})
    @form_create.push({index:"画像説明（altタグ）", column:"item8_image_alt", required:false, type:"text_field", tt:["検索エンジンに画像の内容を説明するために入力します。"]})
    @form_create.push({index:"添付画像８", column:"content_image8", required:false, type:"image", del_id:"content_image8_del_id"})


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
    @destroy_item = Post.find(params[:destroy_id])
    destroy_item(@destroy_item, @destroy_item.title)
  end

  def publish
    @confirm = ""
    @publish_item = Post.find(params[:publish_id])
    
    @info_flg = "false"
    @publish_path = post_publish_path(publish_id: @publish_item.id, info_flg: @info_flg)

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
      :main_image, :thumbnail
    )
  end

end
