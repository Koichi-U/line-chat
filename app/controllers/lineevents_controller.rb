class LineeventsController < ApplicationController
  
  require 'line/bot'
  
  # callbackアクションのCSRFトークン認証を無効
  protect_from_forgery :except => [:callback]
  
  def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_id = ENV["LINE_CHANNEL_ID"]
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
  }
  end
  
  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    
    unless client.validate_signature(body, signature)
      error 400 do 'Bad Request' end
    end
    
    status_code = 200
    status_message = 'OK'
    
    events = client.parse_events_from(body)
    events.each do |event|
      if event.is_a?(Line::Bot::Event::Message)
        if event.type == "text"
          message = {
            type: 'text',
            text: event.message['text']
          }
          response = client.reply_message(event['replyToken'], message)
          if response.code != 200
            status_code = response.code
            status_message = response.message
          end
        end
      end
      userId = event['source']['userId']  #userId取得
      p 'UserID: ' + userId # UserIdを確認
    end
    
    p 'Code:' + status_code + '  message:' + status_message
    render status: status, json: { status: status_code, message: status_message }
  end

end
