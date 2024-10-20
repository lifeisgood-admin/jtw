class JobsController < ApplicationController
  layout 'for_admin'
  before_action :login_required
  before_action :admin_partner_info_create, only: [:index]
  # before_action :auth_verification

  def index
    @partner = Partner.find(params[:partner_id])
    @jobs = Job.where(partner_id: @partner.id)
    
    @setting = []
    #setting.push([項目名,PC表示順,幅,over_admin,sp_menu])
    #下記の並び順はスマホでの順番になる
    @setting.push(["タイトル",1,15,"","true"])
    @setting.push(["ID",0,3,"",""])
    @setting.push(["公開",2,7,"",""])
    @setting.push(["プレビュー",4,7,"",""])
    @setting.push(["編集",5,7,"",""])
    @setting.push(["削除",6,7,"",""])

    @data = []
    @data.push(@setting)

    @jobs.each do |item|
      @row = []
      #row.push([表示内容,表示形式,色,リンク先,ウィンドウ])
      @row.push([item.title,"text","","",""])
      @row.push([item.id,"text","","",""])
      @row.push(["公開",item.disclose_flg,job_publish_path(publish_id: item.id)]) #公開は予約対応で、["公開",disclose_flg,path]
      @row.push(["プレビュー","btn","btn-outline-primary",job_path(partner_url: @partner.url, job_id: item.id),"blank"])
      @row.push(["編集","btn","btn-outline-primary",job_edit_path(job_id: item.id),""])
      @row.push(["削除","btn","btn-outline-secondary",job_destroy_path(destroy_id: item.id),"remote_destroy"])
      @data.push(@row)
    end

  end

  def edit
    @action_name = action_name #同一コントローラー内に二つのeditがあるときのため
    @partner = Partner.find(params[:partner_id])

    # @job_index_categories = JobIndexCategory.all
    # @location_index_categories = LocationIndexCategory.all
    # @feature_index_categories = FeatureIndexCategory.all

    if request.get? then
      if params[:job_id]
        @item = Job.find(params[:job_id])
        if params[:alert]
          @alert = true
          request.env["HTTP_REFERER"] = job_index_path
        end
      elsif
        @item = Job.new
      end
    elsif request.post? then
      @item = Job.new(job_params)
      @alert = true
      if @item.valid?
        @item.save!
        redirect_to action: :edit, job_id: @item.id, alert: true
        return
      else
        @item.errors.add(:base, '画像を選択していた場合、再度添付してください。')
      end
    elsif request.patch? then
      ActiveStorage::Blob.unattached.find_each(&:purge)
      @item_new = Job.new(job_params)
      @item = Job.find(params[:job_id])
      @item_old = Job.find(params[:job_id])

      #先に画像のリレーションを外してからvalidationすることでエラーが出ても画像は更新されている
      if params[:job][:image_ids]
        params[:job][:image_ids].each do |image_id|
          ActiveStorage::Attachment.find(image_id).delete
        end
      end

      if !@item.update(job_params)
        @item.errors.add(:base, '画像を選択していた場合、再度添付してください。')
      end
    end

    if @item.id.present?
      #プレビュー用のパス
      @path = job_path(partner_url: @partner.url, job_id: @item.id)
    end

    @form_name = "求人編集"
    #columnのidはダミー、indexのフリーはダミー、年齢の例外処理を作る
    @form_create = []
    @form_create.push({index:"パートナー名", column:"partner_id", required:true, type:"hidden_field", display:@partner.name, hidden_value:@partner.id})
    @form_create.push({index:"公開設定", column:"disclose_flg", required:true, type:"select", option:[["非公開",0],["公開",1]]})

    @form_create.push({group:"【動画】"})
    @text = '<a href="https://support.google.com/youtube/answer/171780?hl=ja" target="_blank" rel="noopener noreferrer"><span class="min-font"><b>取得方法はこちらから</b></span></a><br><span class="min-font">1.説明ページの1~4を実行<br></span><span class="min-font">2.こちらの欄に取得したHTMLコードを入力して保存<br></span>'
    @form_create.push({index:"Youtube URL", column:"movie_url", required:false, type:"text_area", height:"6", ind_desc:[@text]})

    @form_create.push({group:"【画像】"})
    @form_create.push({index:"メインビジュアル（複数可）", column:"images", required:false, type:"file_multi"})

    @form_create.push({group:"【募集内容】"})
    @form_create.push({index:"求人タイトル", column:"title", required:true, type:"text_field"})
    @form_create.push({index:"おすすめラベル", column:"label", required:false, type:"text_field", tt:["求人閲覧画面で、アイコンとして目立つように出力されます。複数入力する場合は半角カンマ「,」で区切ってください。最大５つまで入力可能です。"]})
    @form_create.push({index:"PRポイント", column:"free_comment", required:false, type:"text_area", height:"5"})
    @form_create.push({index:"仕事内容", column:"main_content", required:true, type:"text_area", height:"5"})
    @form_create.push({index:"仕事の醍醐味", column:"job_fun", required:false, type:"text_area", height:"5"})
    @form_create.push({index:"勤務地（表示用）", column:"work_location", required:true, type:"text_area", height:"5"})
    @form_create.push({index:"勤務地（検索用）", column:"id", required:true, type:"text_field_multi", column_set:[["都道府県","pref",""],["市区町村","city",""],["町名番地以下","street",""]]})
    @form_create.push({index:"最寄り駅", column:"station", required:false, type:"text_area", height:"3"})
    @form_create.push({index:"雇用形態", column:"emp_status", required:true, type:"radio_button", another:true, option:[["正社員","正社員"],["契約社員","契約社員"],["パート・アルバイト","パート・アルバイト"],["紹介予定派遣","紹介予定派遣"],["派遣社員","派遣社員"],["業務委託","業務委託"]]})
    @form_create.push({index:"雇用期間・試用期間", column:"trial_period", required:false, type:"text_area", height:"5"})
    @form_create.push({index:"給与形態", column:"income_style", required:true, type:"radio_button", another:true, option:[["年収","年収"],["年俸","年俸"],["月収","月収"],["月給","月給"],["日給","日給"],["時給","時給"],["日給月給","日給月給"]]})
    @form_create.push({index:"想定収入", column:"id", required:true, type:"text_field_multi", column_set:[["","min_income","円～"],["","max_income","円"]], ind_desc:["※半角数字で「,」を入れずにご記入ください。"]})
    @form_create.push({index:"給与詳細", column:"income", required:true, type:"text_area", height:"5", ind_desc:["例：基本給・昇給・その他定額的に払うもの"]})
    @form_create.push({index:"応募資格", column:"qualification", required:false, type:"text_area", height:"5"})
    @form_create.push({index:"求める人材", column:"preferable_exp", required:false, type:"text_area", height:"5"})
    @form_create.push({index:"就業時間（休憩時間・残業時間）", column:"work_time", required:false, type:"text_area", height:"5"})
    @form_create.push({index:"休日・休暇", column:"holiday", required:true, type:"text_area", height:"5"})
    @form_create.push({index:"福利厚生・待遇", column:"treatment", required:true, type:"text_area", height:"5"})
    @form_create.push({index:"就業場所に関する特記事項", column:"work_place_note", required:false, type:"text_area", height:"5"})
    @form_create.push({index:"募集背景", column:"background", required:false, type:"text_area", height:"5"})
    @form_create.push({index:"採用人数", column:"hire_num", required:false, type:"text_field"})
    @text = '<p class="min-font mb-0" style="padding-right:.25rem;">例外を除き、労働者の募集に当たって、年齢制限を設けることはできません。禁止事項に該当しないことを十分にご確認の上記入してください。<br></p><a href="https://www.mhlw.go.jp/content/000596956.pdf" target="_blank" rel="noopener noreferrer"><span class="min-font"><b>例外についてはこちらから</b></span></a>'
    @form_create.push({index:"募集年齢", column:"id", required:false, type:"exceptional", column_set:[["","min_age","歳～"],["","max_age","歳"]], option_column:"age_reason",
                      option:[["選択してください",""],
                              ["定年年齢を上限として、その上限年齢未満の労働者を期間の定めのない労働契約の対象として募集・採用するため","定年年齢を上限として、その上限年齢未満の労働者を期間の定めのない労働契約の対象として募集・採用するため"],
                              ["労働基準法その他の法令の規定により年齢制限が設けられているため","労働基準法その他の法令の規定により年齢制限が設けられているため"],
                              ["長期勤続によるキャリア形成を図る観点から、若年者等を期間の定めのない労働契約の対象として募集・採用するため","長期勤続によるキャリア形成を図る観点から、若年者等を期間の定めのない労働契約の対象として募集・採用するため"],
                              ["技能・ノウハウの継承の観点から、特定の職種において労働者数が相当程度少ない特定の年齢層に限定し、かつ、期間の定めのない労働契約の対象として募集・採用するため","技能・ノウハウの継承の観点から、特定の職種において労働者数が相当程度少ない特定の年齢層に限定し、かつ、期間の定めのない労働契約の対象として募集・採用するため"],
                              ["芸術・芸能の分野における表現の真実性などの要請があるため","芸術・芸能の分野における表現の真実性などの要請があるため"],
                              ["60歳以上の高年齢者、就職氷河期世代（35歳以上55歳未満）または特定の年齢層の雇用を促進する施策（国の施策を活用しようとする場合に限る）の対象となる者に限定して募集・採用するため","60歳以上の高年齢者、就職氷河期世代（35歳以上55歳未満）または特定の年齢層の雇用を促進する施策（国の施策を活用しようとする場合に限る）の対象となる者に限定して募集・採用するため"]
                              ], ind_desc:[@text]})
    @form_create.push({index:"選考フロー", column:"selection_process", required:false, type:"text_area", height:"5"})
    @form_create.push({index:"フリー", column:"id", required:false, type:"free_item", free_set:[["text_field","free_title1"],["text_area","free_content1"]]})
    @form_create.push({index:"フリー", column:"id", required:false, type:"free_item", free_set:[["text_field","free_title2"],["text_area","free_content2"]]})
    @form_create.push({index:"フリー", column:"id", required:false, type:"free_item", free_set:[["text_field","free_title3"],["text_area","free_content3"]]})

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
    @destroy_item = Job.find(params[:destroy_id])
    destroy_item(@destroy_item, @destroy_item.title)
  end

  def publish
    @confirm = ""
    @publish_item = Job.find(params[:publish_id])

    @info_flg = "false"
    @publish_path = job_publish_path(publish_id: @publish_item.id, info_flg: @info_flg)

    publish_item(@confirm, @publish_item, @publish_path)
  end

  private

  def job_params
    params.require(:job).permit(
      :partner_id, :movie_url,
      :title, :main_content, :free_comment,
      :background, :job_fun, :qualification, :preferable_exp, :hire_num,
      :min_age, :max_age, :age_reason,
      :emp_status, :trial_period, :work_time,
      :work_location, :pref, :city, :street, :station,
      :income, :income_style, :min_income, :max_income,
      :treatment, :holiday, :work_place_note, :selection_process,
      :free_title1, :free_content1,
      :free_title2, :free_content2,
      :free_title3, :free_content3,
      :label,
      :disclose_flg,
      images:[], image_ids:[],
      search_job:[], search_feature:[], search_location:[]
    )
  end
end
