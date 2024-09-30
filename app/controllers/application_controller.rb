class ApplicationController < ActionController::Base
    #viewでもcontrollerのメソッドを使いたいときはhelper_methodを使う
    helper_method :current_user
  
    private
    #Rubyのprivateは継承先でも参照できる
  
    def current_user
        @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
    end
  
    def login_required
        redirect_to login_path unless current_user
    end
  
    def require_admin
        raise_redirect unless current_user.agency.super_admin_flg? || current_user.agency.admin_flg?
    end
  
    def require_super_admin
        raise_redirect unless current_user.agency.super_admin_flg?
    end
  
    def destroy_item(item, name)
        item.destroy
        flash.now[:notice] = "「#{name}」を削除しました。"
        render "admin_partial/destroy/destroy"
    end

    def publish_item(confirm, item, path)
        item.disclose_flg = (item.disclose_flg-1).abs
        item.save!

        respond_to do |format|
            format.js
            render "admin_partial/publish/publish"
        end
    end

    def patch_image_fallback(new_image, old_image, now_image)
        if new_image.attached? && old_image.attached?
            now_image.attach(ActiveStorage::Blob.find(old_image.blob.id))
        end
    end
  
    def patch_image_delete(image, param)
        if param.present?
            image.purge
        end
    end
  
    def raise_redirect
        flash[:danger] = "不正な処理です。"
        redirect_to admin_top_path
    end
  
    def raise_not_found
        raise ActiveRecord::RecordNotFound
    end
  
    def auth_verification
        if !current_user.agency.super_admin_flg?
            if params[:agency_id]
                @agency = Agency.find(params[:agency_id])
                raise_not_found unless @agency.id == current_user.agency_id || @agency.admin_id == current_user.agency_id
            end
            if params[:partner_id]
                @partner = Partner.find(params[:partner_id])
                raise_not_found unless @partner.agency_id == current_user.agency_id || @partner.agency.admin_id == current_user.agency_id
                raise_not_found unless @partner.agency_id == @agency.id
            end
            if params[:topic_category_id]
                @topic_category = TopicCategory.find(params[:topic_category_id])
                raise_not_found unless @topic_category.partner.agency_id == current_user.agency_id || @topic_category.partner.agency.admin_id == current_user.agency_id
                raise_not_found unless @topic_category.partner_id == @partner.id
            end
            if params[:topic_id]
                @topic = Topic.find(params[:topic_id])
                raise_not_found unless @topic.topic_category.partner.agency_id == current_user.agency_id || @topic.topic_category.partner.agency.admin_id == current_user.agency_id
                raise_not_found unless @topic.topic_category.partner_id == @partner.id
                raise_not_found unless @topic.topic_category_id == @topic_category.id
            end
            if params[:job_id]
                @job = Job.find(params[:job_id])
                raise_not_found unless @job.partner.agency_id == current_user.agency_id || @job.partner.agency.admin_id == current_user.agency_id
                raise_not_found unless @job.partner_id == @partner.id
            end
            if params[:user_id]
                @user = User.find(params[:user_id])
                raise_not_found unless @user.agency_id == current_user.agency_id || @user.agency.admin_id == current_user.agency_id
                raise_not_found unless @user.agency_id == @agency.id
            end
        end
    end
  
    def get_partner
        @partner = Partner.find_by(url: params[:partner_url])
    end

    def menu_create
        @partner = Partner.find_by(url: params[:partner_url])
        @menu_topic_categories = TopicCategory.where(partner_id: @partner.id).where(disclose_flg: "1").where.not(menu_name: "").order('display_order ASC')
        @menu_name = @menu_topic_categories.pluck(:menu_name).uniq
        if TopicCategory.find_by(content_type: "求人").present?
            @menu_name_job = TopicCategory.find_by(content_type: "求人").menu_name
        end
  
        @menu = []
        @menu_name.each do |obj|
            if @menu_name_job.present? && obj == @menu_name_job
                if @partner.jobs.where(disclose_flg: "1").size != 0
                    @menu.push([obj, "job", ""])
                end
            else
                @tmp_topic_category = TopicCategory.includes(:topics).where(topic_categories: {partner_id: @partner.id, disclose_flg: "1", menu_name: obj}).where(topics: {disclose_flg: "1"}).order('topic_categories.display_order ASC')
                if @tmp_topic_category.size != 0
                    @menu.push([obj, "topic", @tmp_topic_category])
                end
            end
        end
    end
end
  