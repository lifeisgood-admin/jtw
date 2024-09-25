require 'csv'

csv_data = CSV.generate(headers: true) do |csv|
  cols = {
    'ID' => ->(u){ u.id},
    '掲載順' => ->(u){ u.display_order},
    'カテゴリー名' => ->(u){ u.name},
    '削除フラグ' => ->(u){ u.delete_flg},
  }

  # header
  csv << cols.keys

  # body
  @categories.each do |obj|
    csv << cols.map{|k, col| col.call(obj) }
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