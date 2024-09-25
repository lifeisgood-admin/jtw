class JobsController < ApplicationController
  layout 'for_admin'
  before_action :login_required
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
    @partner = Partner.find(params[:partner_id])

    # @job_index_categories = JobIndexCategory.all
    # @location_index_categories = LocationIndexCategory.all
    # @feature_index_categories = FeatureIndexCategory.all

    if request.get? then
      if params[:job_id]
        @job = Job.find(params[:job_id])
        if params[:alert]
          @alert = true
          request.env["HTTP_REFERER"] = job_index_path
        end
      elsif
        @job = Job.new
      end
    elsif request.post? then
      @job = Job.new(job_params)
      if @job.valid?
        @job.save!
        redirect_to action: :edit, job_id: @job.id, alert: true
        return
      else
        @job.errors.add(:base, '画像を選択していた場合、再度添付してください。')
      end
    elsif request.patch? then
      ActiveStorage::Blob.unattached.find_each(&:purge)
      @job_new = Job.new(job_params)
      @job = Job.find(params[:job_id])
      @job_old = Job.find(params[:job_id])

      #先に画像のリレーションを外してからvalidationすることでエラーが出ても画像は更新されている
      if params[:job][:image_ids]
        params[:job][:image_ids].each do |image_id|
          ActiveStorage::Attachment.find(image_id).delete
        end
      end

      if !@job.update(job_params)
        @job.errors.add(:base, '画像を選択していた場合、再度添付してください。')
      end
    end

    if @job.id.present?
      #プレビュー用のパス
      @path = job_path(partner_url: @partner.url, job_id: @job.id)
    end

    respond_to do |format|
      format.html
      format.js {
        @item = @job
        @model_name = "job"
        @alert = true
        render "admin_partial/edit_error/edit_error"
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
    @publish_path = job_publish_path(publish_id: @publish_item.id)

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
