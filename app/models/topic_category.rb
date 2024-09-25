class TopicCategory < ApplicationRecord
    belongs_to :partner
    has_many :topics #誤操作で消えないようにあえてdependent destroyしない
    has_one_attached :thumbnail, dependent: :destroy

    validate :total_validation

    def total_validation
        errors.add(:content_type, 'コンテンツタイプを入力してください。') if content_type.blank?
        name.blank? ? errors.add(:name, 'カテゴリー名を入力してください。') : name_validation
        display_order_validate
        errors.add(:display_style, 'トップページ表示形式を入力してください。') if display_style.blank?
        thumbnail_validation
    end

    def name_validation
        if TopicCategory.where(partner_id: partner_id).where.not(id: id).where(name: name).exists?
            errors.add(:name, '同じカテゴリー名はすでに使用されています。変更してください。')
        end
    end

    def display_order_validate
        if !display_order.blank? && display_order == 0
            errors.add(:display_order, "表示順を入力する際は、1以上の半角数字で入力してください。")
        end
    end

    def thumbnail_validation
        if display_style.present?
            if display_style.match?(/^.*画像.*$/)
                if !thumbnail.attached?
                    errors.add(:thumbnail, '画像を添付してください。')
                elsif !images?(thumbnail)
                    errors.add(:thumbnail, '画像として添付できるのは、jpg、gif、png形式のみです。')
                    thumbnail.purge
                end
            end
        end
    end
    def images?(img)
        %w[image/jpg image/jpeg image/gif image/png].include?(img.blob.content_type)
    end
end
