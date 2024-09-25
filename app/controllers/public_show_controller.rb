class PublicShowController < ApplicationController
  layout 'for_partner', only: [:partner_top, :partner_info, :partner_privacy_policy, :topic_list, :topic, :job_list, :job, :post]
  before_action :get_partner, only: [:partner_top, :partner_info, :partner_privacy_policy, :topic_list, :topic, :job_list, :job, :post]
  before_action :menu_create, only: [:partner_top, :partner_info, :partner_privacy_policy, :topic_list, :topic, :job_list, :job, :post]

  def general_top
  end
  def about
  end
  def blog
  end

  def search
    if request.fullpath == "job"
    elsif request.fullpath == "ambassador"
    elsif request.fullpath == "professional"
    elsif request.fullpath == "education"
    elsif request.fullpath == "worker"
    elsif request.fullpath == "selection"
    end
  end

  def partner_top
    disclose_check(@partner, nil, nil)

    @topic_categories = TopicCategory.includes(:topics).where(topic_categories: {partner_id: @partner.id, disclose_flg: "1"}).where(topics: {disclose_flg: "1"})
                        .or(TopicCategory.includes(:topics).where(topic_categories: {partner_id: @partner.id, disclose_flg: "1", content_type: "求人"}))
                        .or(TopicCategory.includes(:topics).where(topic_categories: {partner_id: @partner.id, disclose_flg: "1", content_type: "コンテンツ無し"}))
                        .order('topic_categories.display_order ASC')

    @css = ""
    if @partner.catch_copy_position == "right"
      @css += ".partner_top .main_visual .image_area .catch_copy {right:0%;transform:translate(-100%, -50%);-webkit-transform:translate(-100%, -50%);}"
    elsif @partner.catch_copy_position == "left"
      @css += ".partner_top .main_visual .image_area .catch_copy {left:0%;transform:translate(0%, -50%);-webkit-transform:translate(0%, -50%);}"
    end
  end

  def prtner_info
  end

  def partner_privacy_policy
    disclose_check(@partner, nil, nil)
  end

  def topic_list
    @topic_category = TopicCategory.find(params[:topic_category_id])
    disclose_check(@partner, @topic_category, nil)

    @topics = Topic.where(topic_category_id: @topic_category.id).where(disclose_flg: 1)

    @topic_categories = TopicCategory.includes(:topics).where(topic_categories: {partner_id: @partner.id, disclose_flg: "1"}).where(topics: {disclose_flg: "1"})
    .or(TopicCategory.includes(:topics).where(topic_categories: {partner_id: @partner.id, disclose_flg: "1", content_type: "求人"}))
    .or(TopicCategory.includes(:topics).where(topic_categories: {partner_id: @partner.id, disclose_flg: "1", content_type: "コンテンツ無し"}))
    .order('topic_categories.display_order ASC')
  end

  def topic
    @topic_category = TopicCategory.find(params[:topic_category_id])
    @topic = Topic.find(params[:topic_id])
    disclose_check(@partner, @topic_category, @topic)

    @topic_categories = TopicCategory.includes(:topics).where(topic_categories: {partner_id: @partner.id, disclose_flg: "1"}).where(topics: {disclose_flg: "1"})
                        .or(TopicCategory.includes(:topics).where(topic_categories: {partner_id: @partner.id, disclose_flg: "1", content_type: "求人"}))
                        .or(TopicCategory.includes(:topics).where(topic_categories: {partner_id: @partner.id, disclose_flg: "1", content_type: "コンテンツ無し"}))
                        .order('topic_categories.display_order ASC')

    @content = []
    @content.push([@topic.item1_label, @topic.item1_content, @topic.content_image1.attached?, @topic.content_image1, @topic.item1_position, @topic.item1_image_alt, @topic.item1_movie_url])
    @content.push([@topic.item2_label, @topic.item2_content, @topic.content_image2.attached?, @topic.content_image2, @topic.item2_position, @topic.item2_image_alt, @topic.item2_movie_url])
    @content.push([@topic.item3_label, @topic.item3_content, @topic.content_image3.attached?, @topic.content_image3, @topic.item3_position, @topic.item3_image_alt, @topic.item3_movie_url])
    @content.push([@topic.item4_label, @topic.item4_content, @topic.content_image4.attached?, @topic.content_image4, @topic.item4_position, @topic.item4_image_alt, @topic.item4_movie_url])
    @content.push([@topic.item5_label, @topic.item5_content, @topic.content_image5.attached?, @topic.content_image5, @topic.item5_position, @topic.item5_image_alt, @topic.item5_movie_url])
    @content.push([@topic.item6_label, @topic.item6_content, @topic.content_image6.attached?, @topic.content_image6, @topic.item6_position, @topic.item6_image_alt, @topic.item6_movie_url])
    @content.push([@topic.item7_label, @topic.item7_content, @topic.content_image7.attached?, @topic.content_image7, @topic.item7_position, @topic.item7_image_alt, @topic.item7_movie_url])
    @content.push([@topic.item8_label, @topic.item8_content, @topic.content_image8.attached?, @topic.content_image8, @topic.item8_position, @topic.item8_image_alt, @topic.item8_movie_url])
  end
  
  def job_list
    disclose_check(@partner, nil, nil)
    
    @jobs = Job.where(partner_id: @partner.id).where(disclose_flg: 1)
    @topic_categories = TopicCategory.includes(:topics).where(topic_categories: {partner_id: @partner.id, disclose_flg: "1"}).where(topics: {disclose_flg: "1"})
                        .or(TopicCategory.includes(:topics).where(topic_categories: {partner_id: @partner.id, disclose_flg: "1", content_type: "求人"}))
                        .or(TopicCategory.includes(:topics).where(topic_categories: {partner_id: @partner.id, disclose_flg: "1", content_type: "コンテンツ無し"}))
                        .order('topic_categories.display_order ASC')
  end

  def job
    @job = Job.find(params[:job_id])
    disclose_check(@partner, nil, @job)

    @job_overview = []
    @job_overview.push(["仕事内容", @job.main_content])
    @job_overview.push(["仕事の醍醐味", @job.job_fun])
    @job_overview.push(["PRポイント", @job.free_comment])
    @job_overview.push(["求める人物像", @job.preferable_exp])

    @job_detail = []
    @job_detail.push(["雇用形態", @job.emp_status])
    @job_detail.push(["給与", income_content = create_income( @job.income_style, @job.min_income, @job.max_income )])
    @job_detail.push(["給与詳細", @job.income])
    @job_detail.push(["勤務時間", @job.work_time])
    @job_detail.push(["勤務地", @job.work_location])
    @job_detail.push(["最寄り駅", @job.station])
    @job_detail.push(["就業場所に関する特記事項", @job.work_place_note])
    @job_detail.push(["応募資格", @job.qualification])
    @job_detail.push(["年齢制限", age_content = create_age( @job.min_age, @job.max_age, @job.age_reason )])
    @job_detail.push(["募集背景", @job.background])
    @job_detail.push(["福利厚生・待遇", @job.treatment])
    @job_detail.push(["休日・休暇", @job.holiday])
    @job_detail.push(["試用期間", @job.trial_period])
    @job_detail.push(["選考プロセス", @job.selection_process])
    @job_detail.push(["採用予定人数", @job.hire_num])
    @job_detail.push([@job.free_title1, @job.free_content1])
    @job_detail.push([@job.free_title2, @job.free_content2])
    @job_detail.push([@job.free_title3, @job.free_content3])


    @partner_info = []
    @partner_info.push(["会社名", @partner.name])
    @partner_info.push([@partner.info1_item, @partner.info1_content])
    @partner_info.push([@partner.info2_item, @partner.info2_content])
    @partner_info.push([@partner.info3_item, @partner.info3_content])
    @partner_info.push([@partner.info4_item, @partner.info4_content])
    @partner_info.push([@partner.info5_item, @partner.info5_content])
    @partner_info.push([@partner.info6_item, @partner.info6_content])
    @partner_info.push([@partner.info7_item, @partner.info7_content])
    @partner_info.push([@partner.info8_item, @partner.info8_content])
    @partner_info.push([@partner.info9_item, @partner.info9_content])
    @partner_info.push([@partner.info10_item, @partner.info10_content])

    @topic_categories = TopicCategory.includes(:topics).where(topic_categories: {partner_id: @partner.id, disclose_flg: "1"}).where(topics: {disclose_flg: "1"})
                        .or(TopicCategory.includes(:topics).where(topic_categories: {partner_id: @partner.id, disclose_flg: "1", content_type: "求人"}))
                        .or(TopicCategory.includes(:topics).where(topic_categories: {partner_id: @partner.id, disclose_flg: "1", content_type: "コンテンツ無し"}))
                        .order('topic_categories.display_order ASC')
  end

  def post
    @post = Post.find(params[:post_id])
    disclose_check(@partner, nil, @post)

    @content = []
    @content.push([@post.item1_label, @post.item1_content, @post.content_image1.attached?, @post.content_image1, @post.item1_position, @post.item1_image_alt, @post.item1_movie_url])
    @content.push([@post.item2_label, @post.item2_content, @post.content_image2.attached?, @post.content_image2, @post.item2_position, @post.item2_image_alt, @post.item2_movie_url])
    @content.push([@post.item3_label, @post.item3_content, @post.content_image3.attached?, @post.content_image3, @post.item3_position, @post.item3_image_alt, @post.item3_movie_url])
    @content.push([@post.item4_label, @post.item4_content, @post.content_image4.attached?, @post.content_image4, @post.item4_position, @post.item4_image_alt, @post.item4_movie_url])
    @content.push([@post.item5_label, @post.item5_content, @post.content_image5.attached?, @post.content_image5, @post.item5_position, @post.item5_image_alt, @post.item5_movie_url])
    @content.push([@post.item6_label, @post.item6_content, @post.content_image6.attached?, @post.content_image6, @post.item6_position, @post.item6_image_alt, @post.item6_movie_url])
    @content.push([@post.item7_label, @post.item7_content, @post.content_image7.attached?, @post.content_image7, @post.item7_position, @post.item7_image_alt, @post.item7_movie_url])
    @content.push([@post.item8_label, @post.item8_content, @post.content_image8.attached?, @post.content_image8, @post.item8_position, @post.item8_image_alt, @post.item8_movie_url])
  end

  private

  def disclose_check(partner, category, obj)
    if current_user
      if !(current_user.partner_id == partner.id || current_user.partner_id.blank?)
        raise Forbidden
      end
    elsif partner.disclose_flg == 0
      raise ActiveRecord::RecordNotFound
    elsif category.present?
      if category.disclose_flg == 0
        raise ActiveRecord::RecordNotFound
      end
    elsif obj.present?
      if obj.disclose_flg == 0
        raise ActiveRecord::RecordNotFound
      end
    end
  end

  def create_income( income_style, min_income, max_income )
    income_content = "給与形態：" + income_style + "\n\n"
    if min_income.present?
      if min_income > 10000
        if min_income % 10000 > 0
          min_income = min_income/10000.to_f.floor(1)
        else
          min_income = min_income/10000
        end
        min_income = min_income.to_s(:delimited) + "万円"
      else
        min_income = min_income.to_s(:delimited) + "円"
      end
      income_content = income_content + min_income
    end
    income_content = income_content + " ～ "
    if max_income.present?
      if max_income > 10000
        if max_income % 10000 > 0
          max_income = max_income/10000.to_f.floor(1)
        else
          max_income = max_income/10000
        end
        max_income = max_income.to_s(:delimited) + "万円"
      else
        max_income = max_income.to_s(:delimited) + "円"
      end
      income_content = income_content + max_income
    end
    return income_content
  end

  def create_age( min_age, max_age, age_reason )
    age_content = ""
    if min_age.present?
      min_age = min_age.to_s + "歳"
      age_content = age_content + min_age
    end
    if min_age.present? || max_age.present?
      age_content = age_content + " ～ "
    end
    if max_age.present?
      max_age = max_age.to_s + "歳"
      age_content = age_content + max_age
    end
    if age_reason.present?
      age_content = age_content + "\n\n" + "【制限理由】\n" + age_reason
    end
    return age_content
  end

end
