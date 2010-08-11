# -*- coding: utf-8 -*-
Session.pre_send_message_timeline_status do |sender, e|

  #変数とか。
  client_source = e.status.source.sub(/<a.*">/,"").sub(/<\/a>/,"").chomp
  #"
  name = e.status.user.name.chomp
  user_protected = ""
  location = e.status.user.location.chomp
  
  
  #振り分けに引っ掛かるのがうっとおしいので書いたんだけど、どう考えても頭悪い手法だから直したいし、誰かruby教えてください。
  name = name.gsub(/秋葉原/, "秋.葉.原")
  name = name.gsub(/アキ(ハバラ|ヨド)/, "ア.キ.バ")
  name = name.gsub(/あき(はばら|ば)/, "あ.き.は.ば.ら")
  name = name.gsub(/([aA]kiba|[aA]kihabara)/, "A.k.i.b.a")
  name = name.gsub(/リナカフェ|りなかふぇ|ﾘﾅｶﾌｪ|リナックス[\s・]?カフェ|ﾘﾅｯｸｽ[\s・]?ｶﾌｪ/, "リ.ナ.カ.フ.ェ")
  name = name.gsub(/秋月/, "秋.月")
  name = name.gsub(/千石/, "千.石")
  
  location = location.gsub(/秋葉原/, "秋.葉.原")
  location = location.gsub(/アキ(ハバラ|ヨド)/, "ア.キ.バ")
  location = location.gsub(/あき(はばら|ば)/, "あ.き.は.ば.ら")
  location = location.gsub(/([aA]kiba|[aA]kihabara)/, "A.k.i.b.a")
  location = location.gsub(/リナカフェ|りなかふぇ|ﾘﾅｶﾌｪ|リナックス[\s・]?カフェ|ﾘﾅｯｸｽ[\s・]?ｶﾌｪ/, "リ.ナ.カ.フ.ェ")
  location = location.gsub(/秋月/, "秋.月")
  location = location.gsub(/千石/, "千.石")
  
  
  #各種情報の整形。
  name_disp = " (name #{name})"
  
  if location != ""
    location = " (from #{location})"
  end
  
  if e.status.user.protected == TRUE
    user_protected = "¶ "
  end
  
  client_source_disp = " (via #{client_source})"
  
  
  #なるほど四時じゃねーなどのフィルタ。
#  if client_source == "なるほど四時じゃねーの"
#    e.cancel = true
#  end
  
  #変数代入して終わり。
  e.text  =  "#{user_protected}#{e.text}#{client_source_disp}#{location}#{name_disp}"

end