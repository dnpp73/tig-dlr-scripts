# -*- coding: utf-8 -*-
Session.pre_send_message_timeline_status do |sender, e|
  
  #変数とか。
  client_source = e.status.source.sub(/<a.*">/,"").sub(/<\/a>/,"").chomp.to_s   #"
  name = e.status.user.name.chomp.to_s
  name_disp = ""
  user_protected = ""
  location = e.status.user.location.chomp.to_s
  location_disp = ""
  
  #nameの整形。フォーマットはお好みで変えると良いと思う。
  name_disp = "(name #{name})"
  
  #locationの整形。フォーマットはお好みで変えると良いと思う。
  if location != ""
    location_disp = "(from #{location})"
  end
  
  #protectedの整形。\x03の後の数字がIRCの制御文字なので色が変わる。事故回避のためprotectedだけこっちに書いた。
  if e.status.user.protected == TRUE
    user_protected = "\x033¶\x03 "
  end
  
  #client_sourceの整形。フォーマットはお好みで変えると良いと思う。
  client_source_disp = "(via #{client_source})"
  
  #公式RTの色を変えて区別付きやすくする。\x03の後の数字がIRCの制御文字なので色が変わる。
  ort_re = Regexp.new("(^♻ RT @[a-zA-Z0-9_]+)")
  ort_re  =~  e.text
  ort_hit = $1
  e.text  =  e.text.gsub(ort_re, "\x032#{ort_hit}\x03")
  
  
  
  #ここで定義したクライアントからのtweetをdrop。
  #主になる四時フィルタ。
  deny_client_source = [
  "なるほど四時じゃねーの",
  "緊急災害支援ツイッター募金"
  ]
  
  #ここで定義した単語が /(name|location|client_source)/ にあれば hoge -> h.o.g.e と整形する。
  #Topic を設定して抽出チャンネル作ると一々ひっかかるの回避。
  keyword_hit_single = [
  "新宿",
  "馬場",
  "池袋",
  "本郷",
  "駒場",
  "渋谷",
  "秋葉原",
  "アキバ",
  "アキハバラ",
  "リナカフェ",
  "おふとん大陸"
  ]
  
  #ここで定義した単語が /(name|location|client_source)/ にあれば hoge -> h..o..g..e と整形する。
  #例外として client_source が Tumblr からの場合のみ e.text の中も hoge -> h..o..g..e と整形してる。誰かがReblog する度に呼ばれてうっとおしいので。
  keyword_hit_double = [
  "dnpp",
  "DNPP"
  ]
  
  
  
  #deny_client_source で定義されたクライアントとマッチしたものからのtweetを捨てる。
  deny_client_source.each do |d1|
    if client_source == d1.to_s
      e.cancel = true
    end
  end
  
  #/(name|location|client_source)/ に keyword_hit_single で定義された単語があれば hoge -> h.o.g.e と整形する。
  keyword_split_ary_single = []
  keyword_escape_single = ""
  keyword_hit_single.each do |k1|
    keyword_split_ary_single = k1.split(//u)
    keyword_escape_single = ""
    keyword_split_ary_single.each do |k2|
      keyword_escape_single = keyword_escape_single + k2.to_s + "."
    end
    keyword_escape_single = keyword_escape_single.chop.to_s
    
    re = Regexp.new(k1)
    name_disp = name_disp.gsub(re,keyword_escape_single)
    location_disp = location_disp.gsub(re,keyword_escape_single)
    client_source_disp = client_source_disp.gsub(re,keyword_escape_single)
    
  end
  
  #/(name|location|client_source)/ に keyword_hit_single で定義された単語があれば hoge -> h..o..g..e と整形する。
  keyword_split_ary_double = []
  keyword_escape_double = ""
  keyword_hit_double.each do |k3|
    keyword_split_ary_double = k3.split(//u)
    keyword_escape_double = ""
    keyword_split_ary_double.each do |k4|
      keyword_escape_double = keyword_escape_double + k4.to_s + ".."
    end
    keyword_escape_double = keyword_escape_double.chop.chop
    
    re = Regexp.new(k3)
    name_disp = name_disp.gsub(re,keyword_escape_double)
    location_disp = location_disp.gsub(re,keyword_escape_double)
    client_source_disp = client_source_disp.gsub(re,keyword_escape_double)
    
    #TumblrからのReblog通知がうっとおしいので。
    if client_source == "Tumblr"
      if e.text.include?("http://tumblr.com/") == TRUE
        e.text  =  e.text.gsub(re,keyword_escape_double)
      end
    end
    
  end
  
  
  
  #最後に整形したものを代入して終わり。\x03の後の数字がIRCの制御文字なので色が変わる。Spaceの位置などはお好みで。
  e.text  =  "#{user_protected}#{e.text} \x0314#{client_source_disp} #{location_disp} #{name_disp}"
end
