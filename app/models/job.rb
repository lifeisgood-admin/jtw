class Job < ApplicationRecord
    belongs_to :partner

    has_many_attached :images

    validate :total_validation

    def total_validation
        image_check
        errors.add(:title, '求人タイトルを入力してください。') if title.blank?
        errors.add(:main_content, '仕事内容を入力してください。') if main_content.blank?
        errors.add(:work_location, '勤務地（表示用）を入力してください。') if work_location.blank?
        errors.add(:pref, '都道府県を入力してください。') if pref.blank?
        errors.add(:city, '市区町村を入力してください。') if city.blank?
        errors.add(:street, '町名番地以下を入力してください。') if street.blank?
        errors.add(:emp_status, '雇用形態を入力してください。') if emp_status.blank?
        errors.add(:income_style, '給与形態を入力してください。') if income_style.blank?
        income_validation
        errors.add(:income, '給与詳細を入力してください。') if income.blank?
        errors.add(:holiday, '休日・休暇を入力してください。') if holiday.blank?
        errors.add(:treatment, '福利厚生・待遇を入力してください。') if treatment.blank?
        age_validation
    end

    def image_check
        if images.attached?
            images.each do | img |
                if !images?(img)
                    errors.add(:images, '求人添付画像として添付できるのは、jpg、gif、png形式のみです。')
                    img.purge
                end
            end
        end
    end
    def images?(img)
        %w[image/jpg image/jpeg image/gif image/png].include?(img.blob.content_type)
    end

    def income_validation
        if max_income.blank? && min_income.blank?
            errors.add(:min_income,'想定収入：少なくとも最高収入・最低収入のどちらか一つを入力してください。')
            errors.add(:max_income,'想定収入：少なくとも最高収入・最低収入のどちらか一つを入力してください。')
        end
    end

    def age_validation
        if !max_age.blank? || !min_age.blank?
            errors.add(:age_reason, '年齢制限理由：年齢制限を設ける場合は、年齢制限理由を記入してください。') unless age_reason.present?
        end
    end
end
