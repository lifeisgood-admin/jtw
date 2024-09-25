module ApplicationHelper
    #ビューで使うものがヘルパー
    def text(text) 
        h(text).gsub(/[[:cntrl:]]/,'').html_safe 
    end

    def br_text(text) 
        h(text).gsub(/\R/, "<br>").gsub(/[[:cntrl:]]/,'').html_safe 
    end

    def br_text_code_ok(text) 
        text.gsub(/\R/, "<br>").gsub(/[[:cntrl:]]/,'').html_safe
    end

    def br_text_gfj(text) 
        h(text).gsub(/\R/, "<br>").gsub(/[[:cntrl:]]/,'').gsub(/\"/,'“').html_safe 
    end

    def map_url_trim(text)
        text.gsub("<iframe src=\"", "").gsub("\" width=(.+?)", "")
    end

    def movie_url_trim(text)
        text.gsub("width=\"560\"","").gsub("height=\"315\"","").html_safe
    end

    def slug_trim(text)
        text.gsub("[", "").gsub("]", "").gsub("\"", "").gsub(" ", "").split(",")[1].to_s
    end

    def text_url_to_link(text)
        new_text = h(text)
        new_text.gsub!(/\R/, "<br>") 
        new_text.gsub!(/[[:cntrl:]]/,'') 

        URI.extract(new_text, ["http", "https"]).uniq.each do |url|
            new_text.gsub!(url, "<a href=\"#{url}\" target=\"_blank\">#{url}</a>")
        end

        return new_text
    end

    def original_style(branch)
        #メインカラー
        css = "#header_branch .gnav_branch{ background: #{branch.main_color}; }"
        css += "@media screen and (max-width: 1024px) { #header_branch .gnav_branch{ background: none; } }"
        css += "@media screen and (max-width: 1024px) { #header_branch .gnav_branch .menu_wrap .menu{ background: #{branch.main_color}; } }"
        css += "@media screen and (max-width: 1024px) { #header_branch .gnav_branch .menu_wrap label{ background: #{branch.main_color}; } }"
        css += "@media screen and (max-width: 1024px) { #header_branch .gnav_branch #menu_bar:checked ~ ul{ border-top: 5px solid #{branch.main_color}; border-bottom: 5px solid #{branch.main_color}; } }"
  
        #ボタンカラー
        bright_color , dark_color = color_edit(branch.button_color)
        css += ".entry_btn{ background-color: #{branch.button_color}; border-bottom: solid 5px #{dark_color}; }"
        css += ".entry_btn:hover{ background-color: #{bright_color}; border-bottom: solid 5px #{branch.button_color}; }"
        css += ".entry_btn:active{ border-bottom: solid 2px #{dark_color}; }"
  
        #メニューバーの文字カラー
        css += "#header_branch .gnav_branch ul a{ color: #{branch.menu_letter_color}; }"
        css += "#header_branch .gnav_branch ul a:hover{ color: #{branch.main_color}; }"
  
        return css
    end
  
    def color_edit(hex)
        rgb_array = hex.gsub("#","").each_char.each_slice(2).map{|a| a.join.to_i(16) }
        rgb = ColorCode::RGB.new(r: rgb_array[0], g: rgb_array[1], b: rgb_array[2])

        hsl = rgb.to_hsl
        hsl_hash = hsl.to_hash

        light = hsl_hash[:l]
        light_up = light + (100 - light) * 1 / 5
        light_down = light + (0 - light) * 3 / 5

        light_up_hsl = ColorCode::HSL.new(h: hsl_hash[:h] , s: hsl_hash[:s] , l: light_up)
        bright_color = light_up_hsl.to_s

        light_down_hsl = ColorCode::HSL.new(h: hsl_hash[:h] , s: hsl_hash[:s] , l: light_down)
        dark_color = light_down_hsl.to_s

        return bright_color , dark_color
    end
end
