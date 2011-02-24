# -*- coding: utf-8 -*-

# typoしたチャンネルにnoticeでメッセージとか送りたいんだけど巧くいかない！
# 仕方無いのでとりあえず動作確認が取れたサーバーエラーメッセージを返してるんだけど、
# 誰か巧いやり方知ってる方ぜひ教えてください！
# 
# 僕はAquaSKKを使っているので、typoするとしたらこんな形になるのだけど、
# MicrosoftIMEやGoogleIMEだともっと違う形になると思うので、各自で書き換えてください。
# skkで q を打ってカタカナモードになったときの事を考えてないです。ちょっと悩んでる。

Pattern = '^(?:(?:れ|う|うせ|ぉ|ぱ|ふぁ)? (?:[ぁぃぅぇぉか-ん]|[あいうえお]{2}){1,2}|うんど|[a-z]{0,5} (?:[aiueokgqszjtdnhbfpvmyrwl][aiueo]){1,2})$'

# ステータス更新直前のイベント
Session.pre_send_update_status do |sender, e|
  if Regexp.new(Pattern) =~ e.text
    e.cancel = true
    Session.send_server_error_message("Typoしてると思うよ。")
  end
end