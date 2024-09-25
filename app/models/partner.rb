class Partner < ApplicationRecord
    has_many :users
    has_many :topic_categories
    has_many :jobs
    has_many :posts

    has_one_attached :main_image, dependent: :destroy
    has_one_attached :thumbnail, dependent: :destroy

    validate :total_validation

    def total_validation
        errors.add(:name, '会社名を入力してください。') if name.blank?
        mail.blank? ? errors.add(:mail, '通知先メールアドレスを入力してください。') : mail_validation
        url.blank? ? errors.add(:url, 'URL文字列を入力してください。') : url_validation
        errors.add(:category, '登録カテゴリーを選択してください。') if category.blank?
        errors.add(:privacy_policy, 'プライバシーポリシーを入力してください。') if privacy_policy.blank?
        if !main_image.attached?
            errors.add(:main_image, 'メインビジュアルを添付してください。')
        elsif !images?(main_image)
            errors.add(:main_image, 'メインビジュアルとして添付できるのは、jpg、gif、png形式のみです。')
            main_image.purge
        end
        if !thumbnail.attached?
            errors.add(:thumbnail, 'サムネイルを添付してください。')
        elsif !images?(thumbnail)
            errors.add(:thumbnail, 'サムネイルとして添付できるのは、jpg、gif、png形式のみです。')
            thumbnail.purge
        end
        fulfill_check
    end

    def url_validation
        if Partner.where.not(id: id).where(url: url).exists?
            errors.add(:url, '同じURL文字列はすでに使用されています。変更してください。')
        else
            if url.match?(/.*\s|　.*/)
                errors.add(:url, 'URL文字列にスペースは使用できません。')
            elsif url.match?(/.*\/.*/)
                errors.add(:url, 'URL文字列にスラッシュ「/」は使用できません。')
            end
        end
    end

    def images?(img)
        %w[image/jpg image/jpeg image/gif image/png].include?(img.blob.content_type)
    end

    def mail_validation
        mails = mail.split(",")
        mails.each do | obj |
            if !obj.match?(/\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i)
                errors.add(:mail, "「#{obj}」はメールアドレスの形式を満たしていません。")
            end
        end
    end

    def fulfill_check
        [[info1_item, info1_content],[info2_item, info2_content],[info3_item, info3_content],[info4_item, info4_content],[info5_item, info5_content],
         [info6_item, info6_content],[info7_item, info7_content],[info8_item, info8_content],[info9_item, info9_content],[info10_item, info10_content]
        ].each_with_index do |obj, i|
            if obj[0].present? || obj[1].present?
                if obj[0].blank?
                    case i + 1
                    when 1 then errors.add(:info1_item, "プロフィールに未入力の項目名があります。※１番目")
                    when 2 then errors.add(:info2_item, "プロフィールに未入力の項目名があります。※２番目")
                    when 3 then errors.add(:info3_item, "プロフィールに未入力の項目名があります。※３番目")
                    when 4 then errors.add(:info4_item, "プロフィールに未入力の項目名があります。※４番目")
                    when 5 then errors.add(:info5_item, "プロフィールに未入力の項目名があります。※５番目")
                    when 6 then errors.add(:info6_item, "プロフィールに未入力の項目名があります。※６番目")
                    when 7 then errors.add(:info7_item, "プロフィールに未入力の項目名があります。※７番目")
                    when 8 then errors.add(:info8_item, "プロフィールに未入力の項目名があります。※８番目")
                    when 9 then errors.add(:info9_item, "プロフィールに未入力の項目名があります。※９番目")
                    when 10 then errors.add(:info10_item, "プロフィールに未入力の項目名があります。※１０番目")
                    end
                elsif obj[1].blank?
                    case i + 1
                    when 1 then errors.add(:info1_content, "プロフィールに未入力の内容があります。※１番目")
                    when 2 then errors.add(:info2_content, "プロフィールに未入力の内容があります。※２番目")
                    when 3 then errors.add(:info3_content, "プロフィールに未入力の内容があります。※３番目")
                    when 4 then errors.add(:info4_content, "プロフィールに未入力の内容があります。※４番目")
                    when 5 then errors.add(:info5_content, "プロフィールに未入力の内容があります。※５番目")
                    when 6 then errors.add(:info6_content, "プロフィールに未入力の内容があります。※６番目")
                    when 7 then errors.add(:info7_content, "プロフィールに未入力の内容があります。※７番目")
                    when 8 then errors.add(:info8_content, "プロフィールに未入力の内容があります。※８番目")
                    when 9 then errors.add(:info9_content, "プロフィールに未入力の内容があります。※９番目")
                    when 10 then errors.add(:info10_content, "プロフィールに未入力の内容があります。※１０番目")
                    end
                end
            end
        end
    end
end