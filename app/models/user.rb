class User < ApplicationRecord
    has_secure_password
    belongs_to :partner

    validate :total_validation

    def total_validation
        errors.add(:name, '名前を入力してください。') if name.blank?
        mail.blank? ? errors.add(:mail, '応募通知メールアドレスを入力してください。') : mail_validation
    end

    def mail_validation
        if !mail.match?(/\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i)
            errors.add(:mail, "「#{mail}」はメールアドレスの形式を満たしていません。")
        elsif User.where.not(id: id).where(mail: mail).exists?
            errors.add(:mail, 'メールアドレスはすでに使用されています。変更してください。')
        end
    end
end
