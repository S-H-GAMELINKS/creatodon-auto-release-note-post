require 'net/http'
require 'uri'
require 'json'


ALLOW_KIND = 'post_start_sharing'
ALLOW_USER_NAME = 'username'

def lambda_handler(event:, context:)
    # bodyを変数で受け取る
    body = JSON.parse(event['body'], symbolize_names: true)
    
    kind = body[:kind]
    user_name = body.dig(:user, :name)
    

    # イベントの種類が記事の公開でない or 許可されたユーザー名ではない場合は終了
    return if kind != ALLOW_KIND || user_name != ALLOW_USER_NAME

    cw_title = body.dig(:post, :name)
    release_note_url = body.dig(:sharing, :url)

    token = 'token'
    
    uri = URI.parse('https://gamelinks007.net/api/v1/statuses')
    http = Net::HTTP.new(uri.host, uri.port)
    
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    
    req = Net::HTTP::Post.new(uri.request_uri)
    req["Authorization"] = "bearer #{token}"
    req["Content-Type"] = "application/json"
    
    status = <<STATUS_CONTENT
先ほどサーバーメンテナンスを行ってありますー
    
詳細な変更などは以下のリリースノートを参照して頂ければ幸いですー
#{release_note_url}
    
#Creatodon_info
STATUS_CONTENT
    
    data = {
        "status" => status,
        "spoiler_text" => cw_title,
    }.to_json
    
    req.body = data
    res = http.request(req)

end
