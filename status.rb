Session.pre_send_message_timeline_status do |sender, e|

  #変数とか。
  client_source = e.status.source.sub(/<a.*\">/,"").sub(/<\/a>/,"")
  client_source_disp = " (via #{client_source})"
  user_protected = ""
  location = e.status.user.location
  
  #location情報の整形。
  if location != ""
    location = " (from #{location})"
  end
  
  #Protectedユーザーの区別とか整形とか。
  if e.status.user.protected  == TRUE
    user_protected = "¶ "
  end
  
  #なるほど四時じゃねーの拒否。使いたかったらコメント外す。
#  if client_source == "なるほど四時じゃねーの"
#    e.cancel = true
#  end
  
  #変数代入して終わり。
  e.text  =  "#{user_protected}#{e.text}#{location}#{client_source_disp}"

end