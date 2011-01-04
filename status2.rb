# -*- coding: utf-8 -*-

# 細々とした設定。
ShowName = TRUE
NameColor = "14"
ShowLocation = TRUE
LocationColor = "14"
ShowVia = TRUE
ViaColor = "14"
ChangeOrtColor = TRUE
OrtColor = "2"
ShowProtectedMark = TRUE
ProtectedMarkColor = "3"

# ここで定義したクライアントからのtweetをdrop。
# 主になる四時フィルタ。
DropClient = [
"なるほど四時じゃねーの",
"AndFriends",
"緊急災害支援ツイッター募金",
]

# ここで定義した正規表現にマッチしたtweetをdrop。
# 個人的に嫌いな「多段非公式RT」とか「followme系」とか「【拡散希望】が実際にRTされてるもの」とか「よるほ」とかそういうのを。
# 多段非公式RTとかで [0-9a-zA-Z_] って書いてるのを [\w] って書いても動作しないのなんでなの。
# ConsoleのFilterコンテキストからやればいいという話もあるし、それが真っ当だと思うんだけど、
# そうすると Session.pre_send_message_timeline_status に流れてすらこないので、
# IRCクライアントには送信したくないけどキャプチャしたい、みたいな時に使えるかなと。
DropTweet = "(?:(?:[RQ]T[\s:]\s?[@＠][0-9a-zA-Z_]+[\s:]?\s?.*){3}|#(?:[kK]ohmi[tT]weet|[fF]ollowme[jJ][pP]|[sS]ougo[fF]ollow|[fF]ollow[dD]aibos[hy]uu?)|RT[\s:]\s?[@＠][0-9a-zA-Z_]+[\s:]?\s?[『\[【]\s?(?:拡散|(?:拡散|RT|ＲＴ)(?:希望|推奨|お?願い|お(?:願|ねが)いします。?))\s?[』\]】]|^よるほ[うお-ー!！1１、。]*$)"

# ここで定義した単語が /(name|location|via)/ にあれば hoge -> h.o.g.e と整形する。
# Topicを設定して抽出チャンネル作ると一々ひっかかるの回避。
Escape1 = [
"新宿",
"馬場",
"池袋",
"本郷",
"駒場",
"渋谷",
"秋葉原",
"アキバ",
"リナカフェ",
]

# ここで定義した単語が /(name|location|via)/ にあれば hoge -> h..o..g..e と整形する。
# 例外として via が Tumblr からの場合のみ e.text の中も hoge -> h..o..g..e と整形してる。
# 誰かがReblogする度に呼ばれてうっとおしいので。
Escape2 = [
"ゆうすけ",
"dnpp",
"DNPP",
]

class OptimizeStatuses
  def initialize(e)
    @e = e
    @via = e.status.source.gsub(/\n/," ").sub(/<a.*\">/,"").sub(/<\/a>/,"")
    @name = e.status.user.name.gsub(/\n/," ")
    @location = e.status.user.location.gsub(/\n/," ")
    # 以下のhashはその内DBに放り込むときに使うかもしれない。
    # 現状のTIGから取れるのは多分これで全部？
    @status_user = {
      "screen_name" => e.status.user.screen_name ,
      "name" => e.status.user.name ,
      "user_id" => e.status.user.id.to_s ,
      "desc" => e.status.user.description ,
      "location" => e.status.user.location ,
      "url" => e.status.user.url ,
      "icon" => e.status.user.profile_image_url ,
      #"statuses_count" => e.status.user.statuses_count ,
      #"favourites_count" => e.status.user.favourites_count ,
      #"friends_count" => e.status.user.friends_count ,
      #"followers_count" => e.status.user.followers_count ,
      #"listed_count" => e.status.user.listed_count ,
      "protected" => e.status.user.protected ,
      #e.status.retweeted_status.text.to_s ,
      #e.status.retweeted_status.user.screen_name.to_s ,
      #e.status.retweeted_status.user.created_at.to_s ,
      #e.status.retweeted_status.user.location.to_s ,
      #e.status.retweeted_status.user.name.to_s ,
    }
    @status = {
      "ca" => e.status.created_at.to_s ,
      "via" => e.status.source ,
      "status_id" => e.status.id.to_s ,
      "text" => e.status.text.to_s ,
      "in_reply_to_status_id" => e.status.in_reply_to_status_id.to_s ,
      "in_reply_to_user_id" => e.status.in_reply_to_user_id.to_s ,
      #"in_reply_to_screen_name" => e.status.in_reply_to_screen_name ,
      #"hashtags" => e.status.entities.hashtags ,
    }
  end
  
  def drop_client
    @e.cancel = true if DropClient.index(@via)
  end
  
  def drop_tweet
    @e.cancel = true if ( Regexp.new(DropTweet) =~ @e.status.text )
  end
  
  def line_gsub
    # LimeChat for Macにて、色の15番指定するとそこだけdiv要素になって
    # 改行してるように見える感じに調整したCSSを使って運用してるので。
    # 他のIRCクライアントから見ても破綻しないように。
    @e.text = @e.text.gsub(/\n/,"\x0315 \x03")
  end
  
  def escape(target="",keyword=[""],escape="")
    keyword.each do |key|
      target = target.gsub(Regexp.new(key)) do |match|
        replace = "";match.split(//u).each { |k| replace << k + escape }
        match = replace[0,replace.size-escape.size]
      end
    end
    return target
  end
  
  def add_e_text
    # 公式RTの色変えたり、nameとかlocationとかviaとかprotectedをe.textに付加したり、
    # キーワードのエスケープとかをする。
    @e.text = @e.text.sub(/^♻ RT @[0-9a-zA-Z_]+/) { |hit| "\x03"+OrtColor+hit+"\x03" } if ChangeOrtColor
    @e.text = self.escape(@e.text,Escape2,"..") if ( @via == "Tumblr" )
    name_d = ShowName ? " \x03"+NameColor+"(name "+self.escape(self.escape(@name,Escape1,"."),Escape2,"..")+")\x03" : ""
    location_d = ( ShowLocation && ( @location != "" ) ) ? " \x03"+LocationColor+"(from "+self.escape(self.escape(@location,Escape1,"."),Escape2,"..")+")\x03" : ""
    via_d = ShowVia ? " \x03"+ViaColor+"(via "+self.escape(self.escape(@via,Escape1,"."),Escape2,"..")+")\x03" : ""
    protected = ( ShowProtectedMark && @e.status.user.protected ) ? "\x03"+ProtectedMarkColor+"¶\x03 " : ""
    # 代入して終わり。
    @e.text = protected+@e.text+via_d+location_d+name_d
  end
  
  def main
    self.drop_client
    self.drop_tweet if ( @e.cancel == false )
    self.line_gsub if ( @e.cancel == false )
    self.add_e_text if ( @e.cancel == false )
  end
end

# タイムラインの一ステータスを受信してクライアントに送信する直前のイベント
Session.pre_send_message_timeline_status do |sender, e|
  OptimizeStatuses.new(e).main
end