Session.pre_send_message_timeline_status do |sender, e|

  client_source = e.status.source.sub(/<a.*\">/,"").sub(/<\/a>/,"")
  user_protected = ""
  location = e.status.user.location
  client_source_disp = " (via #{client_source})"
  
  if location != ""
    location = " (from #{location})"
  end
  
  if client_source == "なるほど四時じゃねーの"
    e.cancel = true
  end

  if e.status.user.protected  == TRUE
    user_protected = "¶ "
  end

  e.text  =  "#{user_protected}#{e.text}#{location}#{client_source_disp}"

end