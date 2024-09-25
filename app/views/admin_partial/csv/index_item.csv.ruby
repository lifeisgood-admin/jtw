require 'csv'

csv_data = CSV.generate do |csv|

  csv << %w(ID カテゴリーID カテゴリー名※空欄可。インポート時はカテゴリーIDの内容が反映されます。 掲載順 項目名 削除フラグ)
  @items.each do |obj|
    if @category.class.name == "JobIndexCategory"
      csv << [obj.id, obj.job_index_category_id, obj.job_index_category.name, obj.display_order, obj.name, obj.delete_flg]
    elsif @category.class.name == "LocationIndexCategory"
      csv << [obj.id, obj.location_index_category_id, obj.location_index_category.name, obj.display_order, obj.name, obj.delete_flg]
    elsif @category.class.name == "FeatureIndexCategory"
      csv << [obj.id, obj.feature_index_category_id, obj.feature_index_category.name, obj.display_order, obj.name, obj.delete_flg]
    end
  end

end

# http://orange-factory.com/sample/utf8/code2.html
# https://qiita.com/a_yasui/items/fc6e1c564b5b21482882

def sjis_safe(str)
  [
    ["301C", "FF5E"],
    ["2212", "FF0D"],
    ["00A2", "FFE0"],
    ["00A3", "FFE1"],
    ["00AC", "FFE2"],
    ["2013", "FF0D"],
    ["2014", "2015"],
    ["2016", "2225"],
    ["203E", "FFE3"],
    ["00A0", "0020"],
    ["00F8", "03A6"],
    ["203A", "3009"],
    ["207B", "FF0D"],
    ["0080", ""],
    ["0009", ""],
    ["2002", ""],
    ["2003", ""],
    ["2004", ""],
    ["2005", ""],
    ["2006", ""],
    ["2007", ""],
    ["2008", ""],
    ["2009", ""],
    ["200A", ""],
    ["200B", ""],
    ["3000", ""],
    ["FEFF", ""],
  ].inject(str) do |s, (before, after)|
    s.gsub(
      before.to_i(16).chr('UTF-8'),
      after.to_i(16).chr('UTF-8'))
  end
end

csv_data = sjis_safe(csv_data).encode(Encoding::SJIS, invalid: :replace, undef: :replace)
#csv_data = sjis_safe(csv_data).encode(Encoding::SJIS)