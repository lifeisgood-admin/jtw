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
    @action_name = action_name #同一コントローラー内に二つのeditがあるときのため
    if request.get? then
      if params[:partner_id]
        @item = Partner.find(params[:partner_id])
        if params[:alert]
          @alert = true
          request.env["HTTP_REFERER"] = partner_index_path
        end
      else
        @item = Partner.new
      end
    elsif request.post? then
      @item = Partner.new(partner_params)
      @alert = true
      if @item.valid?
        @item.save!

        redirect_to action: :edit, partner_id: @item.id, alert: true
        return
      else
        @item.errors.add(:base, '画像を選択していた場合、再度添付してください。')
      end
    elsif request.patch? then
      ActiveStorage::Blob.unattached.find_each(&:purge)
      @item_new = Partner.new(partner_params)
      @item = Partner.find(params[:partner_id])
      @item_old = Partner.find(params[:partner_id])

      if !@item.update(partner_params)
        @item.errors.add(:base, '画像を選択していた場合、再度添付してください。')
        #validationエラー時に少なくとも昔の画像が見えるようにする
        patch_image_fallback(@item_new.main_image, @item_old.main_image, @item.main_image)
        patch_image_fallback(@item_new.thumbnail, @item_old.thumbnail, @item.thumbnail)
      end
    end

    @form_name = "パートナー編集"
    #columnのidはダミー、indexのフリーはダミー、年齢の例外処理を作る
    @form_create = []
    @form_create.push({group:"【基本項目】"})
    @form_create.push({index:"キャッチフレーズ", column:"catch_phrase", required:false, type:"text_field"})
    @form_create.push({index:"名称", column:"name", required:true, type:"text_field"})
    @form_create.push({index:"登録カテゴリー", column:"category", required:true, type:"check_box", option:[["求人掲載","求人掲載"],["福利厚生サービス提供","福利厚生サービス提供"],["教育機関","教育機関"],["事業パートナー募集","事業パートナー募集"],["助っ人","助っ人"],["仕事の専門家","仕事の専門家"],["アンバサダー","アンバサダー"]]})
    @form_create.push({index:"公開設定", column:"disclose_flg", required:true, type:"select", option:[["非公開",0],["公開",1]]})
    @form_create.push({index:"URL文字列", column:"url", required:true, type:"text_field", tt:["URLとして使用される文字列を入力してください。他で使用されているものは使用できません。"]})
    @form_create.push({index:"サイトメインカラー", column:"main_color", required:false, type:"color_field"})
    @form_create.push({index:"プライバシーポリシー", column:"privacy_policy", required:true, type:"text_area", height:"5"})
    @form_create.push({index:"通知先MAIL", column:"mail", required:true, type:"text_field", tt:["設定したメールアドレスに、全ての応募通知メールが届きます。複数指定したい場合は半角カンマ「,」区切りで入力してください。編集後は必ず応募テストを行い通知が届くことをご確認ください。"]})

    @form_create.push({group:"【サイト設定】"})
    @form_create.push({index:"サムネイル", column:"thumbnail", required:true, type:"image", del_id:@thumbnail_del_id = ""}) #画像はrequiredではなくdel_idの有無で必須か判断している
    @form_create.push({index:"ラベル", column:"label", required:false, type:"text_field", tt:["半角カンマ区切りで複数追加可能"]})
    @text = '<a href="https://www.google.co.jp/maps/?hl=ja" target="_blank" rel="noopener noreferrer"><span class="min-font"><b>取得はこちらから</b></span></a>
                <span class="min-font">1.自社の所在地住所を検索</span>
                <span class="min-font">2.「共有」をクリック</span>
                <span class="min-font">3.「地図を埋め込む」を選択</span>
                <span class="min-font">4.「HTMLをコピー」をクリックし、枠内に貼り付け</span>'
    @form_create.push({index:"googleマップURL", column:"map_url", required:false, type:"text_area", height:"7", ind_desc:[@text]})

    @form_create.push({group:"【プロフィール】"})
    @form_create.push({index:"フリー", column:"id", required:false, type:"free_item", free_set:[["text_field","info1_item"],["text_area","info1_content"]]})
    @form_create.push({index:"フリー", column:"id", required:false, type:"free_item", free_set:[["text_field","info2_item"],["text_area","info2_content"]]})
    @form_create.push({index:"フリー", column:"id", required:false, type:"free_item", free_set:[["text_field","info3_item"],["text_area","info3_content"]]})
    @form_create.push({index:"フリー", column:"id", required:false, type:"free_item", free_set:[["text_field","info4_item"],["text_area","info4_content"]]})
    @form_create.push({index:"フリー", column:"id", required:false, type:"free_item", free_set:[["text_field","info5_item"],["text_area","info5_content"]]})
    @form_create.push({index:"フリー", column:"id", required:false, type:"free_item", free_set:[["text_field","info6_item"],["text_area","info6_content"]]})
    @form_create.push({index:"フリー", column:"id", required:false, type:"free_item", free_set:[["text_field","info7_item"],["text_area","info7_content"]]})
    @form_create.push({index:"フリー", column:"id", required:false, type:"free_item", free_set:[["text_field","info8_item"],["text_area","info8_content"]]})
    @form_create.push({index:"フリー", column:"id", required:false, type:"free_item", free_set:[["text_field","info9_item"],["text_area","info9_content"]]})
    @form_create.push({index:"フリー", column:"id", required:false, type:"free_item", free_set:[["text_field","info10_item"],["text_area","info10_content"]]})

    @form_create.push({group:"【トップページファーストビュー設定】"})
    @form_create.push({index:"画像表示", column:"main_image_position", required:false, type:"select", option:[["選択してください","center"],["中央寄せ","center"],["右寄せ","right"],["左寄せ","left"],["全体表示","all"]]})
    @form_create.push({index:"メインビジュアル", column:"main_image", required:true, type:"image", del_id:@main_image_del_id = ""}) #画像はrequiredではなくdel_idの有無で必須か判断している
    @form_create.push({index:"キャッチコピー", column:"catch_copy", required:false, type:"text_area", height:"3", ind_desc:["推奨文字数：25~30"]})
    @form_create.push({index:"キャッチコピー配置", column:"catch_copy_position", required:false, type:"select", option:[["選択してください","center"],["中央","center"],["右","right"],["左","left"]]})
    @form_create.push({index:"キャッチコピーテキストカラー", column:"catch_copy_color", required:false, type:"color_field"})

    @form_create.push({group:"【コンタクト設定】"})
    @form_create.push({index:"MAIL", column:"contact_mail", required:false, type:"text_field"})
    @form_create.push({index:"電話番号", column:"contact_tel", required:false, type:"text_field"})
    @form_create.push({index:"Line", column:"contact_line", required:false, type:"text_field"})
    @form_create.push({index:"X", column:"contact_x", required:false, type:"text_field"})
    @form_create.push({index:"FaceBook", column:"contact_fb", required:false, type:"text_field"})
    @form_create.push({index:"Linkedin", column:"contact_linkedin", required:false, type:"text_field"})
    @form_create.push({index:"Instagram", column:"contact_insta", required:false, type:"text_field"})


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
    @destroy_item = Partner.find(params[:destroy_id])
    destroy_item(@destroy_item, @destroy_item.name)
  end

  def publish
    @confirm = "【確認】サイト全体が非公開になります。よろしいですか？"
    @publish_item = Partner.find(params[:publish_id])

    @info_flg = params[:info_flg]
    @publish_path = partner_publish_path(publish_id: @publish_item.id, info_flg: @info_flg)

    publish_item(@confirm, @publish_item, @publish_path)
  end

  private

  def partner_params
    params.require(:partner).permit(
      :name, :catch_phrase,
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
