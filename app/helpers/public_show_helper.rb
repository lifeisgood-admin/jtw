module PublicShowHelper
    def contact_check(partner) 
        flg = false
        [
            partner.contact_line,
            partner.contact_x,
            partner.contact_fb,
            partner.contact_linkedin,
            partner.contact_insta,
            partner.contact_mail,
            partner.contact_tel
        ].each do |obj|
            if obj.present?
                flg = true
            end
        end
            
        return flg
    end
end
