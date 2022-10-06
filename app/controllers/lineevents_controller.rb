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
    
    # client = Line::Bot::Client.new { |config|
    #   config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    #   config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    # }
    
    
    
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      error 400 do 'Bad Request' end
    end
    events = client.parse_events_from(body)
    events.each do |event|
      if event.is_a?(Line::Bot::Event::Message)
        if event.type == "text"
          message = {
            type: 'text',
            text: event.message['text']
          }
          response = client.reply_message(event['replyToken'], message)
          p "response"
          p response
          p event['replyToken']
          # p message.type
        end
      end
      userId = event['source']['userId']  #userId取得
      p 'UserID: ' + userId # UserIdを確認
      
      http_request_body = request.raw_post # Request body string
      hash = OpenSSL::HMAC::digest(OpenSSL::Digest::SHA256.new, ENV["LINE_CHANNEL_SECRET"], http_request_body)
      signature = Base64.strict_encode64(hash)
      p request.headers['HTTP_ACCEPT']
      p signature
      # Compare x-line-signature request header string and the signature
      
      # if event.is_a?(Line::Bot::Event::Message)
      #   p 'UserIDNNN: ' + event.type # UserIdを確認
      #   case event.type
      #   when "text" then
      #     message = {
      #       type: 'text',
      #       text: event.message['text']
      #     }
      #     client.reply_message(event['replyToken'], message)
      #   else
      #     p 'UserIDXXXXX: ' + userId # UserIdを確認
      #   end
      # else
      #   p 'UserIDAAA: ' + userId # UserIdを確認
      # end
    end
    render json: {status: 'SUCCESS'}, status: :ok
  end

end
