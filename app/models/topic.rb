class Topic < ApplicationRecord
    belongs_to :topic_category

    has_one_attached :main_image, dependent: :destroy
    has_one_attached :content_image1, dependent: :destroy
    has_one_attached :content_image2, dependent: :destroy
    has_one_attached :content_image3, dependent: :destroy
    has_one_attached :content_image4, dependent: :destroy
    has_one_attached :content_image5, dependent: :destroy
    has_one_attached :content_image6, dependent: :destroy
    has_one_attached :content_image7, dependent: :destroy
    has_one_attached :content_image8, dependent: :destroy

    validate :total_validation

    def total_validation
        display_order_validate
        if !main_image.attached?
            errors.add(:main_image, 'メインビジュアルを添付してください。')
        elsif !images?(main_image)
            errors.add(:main_image, 'メインビジュアルとして添付できるのは、jpg、gif、png形式のみです。')
            main_image.purge
        end
        errors.add(:title, 'タイトルを入力してください。') if title.blank?
        errors.add(:description, '説明文を入力してください。') if description.blank?
        errors.add(:index_type, '段落形式を入力してください。') if index_type.blank?
        any_presence
        fulfill_check
    end
    def images?(img)
        %w[image/jpg image/jpeg image/gif image/png].include?(img.blob.content_type)
    end

    def display_order_validate
        if !display_order.blank? && display_order == 0
            errors.add(:display_order, "表示順を入力する際は、1以上の半角数字で入力してください。")
        end
    end

    def any_presence
        counter = 0
        [item1_label, item1_content, item2_label,item2_content,
        item3_label, item3_content, item4_label, item4_content,
        item5_label, item5_content, item6_label, item6_content,
        item7_label, item7_content, item8_label, item8_content
        ].each do |obj|
            if !obj.blank?
                counter += 1
            end
        end
        if counter == 0
            errors.add(:base, 'コンテンツが全て空欄では登録できません。')
        end
    end

    def fulfill_check
        [[item1_label, item1_content],[item2_label, item2_content],
        [item3_label, item3_content],[item4_label, item4_content],
        [item5_label, item5_content],[item6_label, item6_content],
        [item7_label, item7_content],[item8_label, item8_content]
        ].each_with_index do |obj, i|
            if obj[0].present? || obj[1].present?
                if obj[0].blank?
                    case i + 1
                    when 1 then errors.add(:item1_label, "コンテンツ1のラベルを入力してください。")
                    when 2 then errors.add(:item2_label, "コンテンツ2のラベルを入力してください。")
                    when 3 then errors.add(:item3_label, "コンテンツ3のラベルを入力してください。")
                    when 4 then errors.add(:item4_label, "コンテンツ4のラベルを入力してください。")
                    when 5 then errors.add(:item5_label, "コンテンツ5のラベルを入力してください。")
                    when 6 then errors.add(:item6_label, "コンテンツ6のラベルを入力してください。")
                    when 7 then errors.add(:item7_label, "コンテンツ7のラベルを入力してください。")
                    when 8 then errors.add(:item8_label, "コンテンツ8のラベルを入力してください。")
                    end
                elsif obj[1].blank?
                    case i + 1
                    when 1 then errors.add(:item1_content, "コンテンツ1の本文を入力してください。")
                    when 2 then errors.add(:item2_content, "コンテンツ2の本文を入力してください。")
                    when 3 then errors.add(:item3_content, "コンテンツ3の本文を入力してください。")
                    when 4 then errors.add(:item4_content, "コンテンツ4の本文を入力してください。")
                    when 5 then errors.add(:item5_content, "コンテンツ5の本文を入力してください。")
                    when 6 then errors.add(:item6_content, "コンテンツ6の本文を入力してください。")
                    when 7 then errors.add(:item7_content, "コンテンツ7の本文を入力してください。")
                    when 8 then errors.add(:item8_content, "コンテンツ8の本文を入力してください。")
                    end
                end
            end
        end
    end
end
