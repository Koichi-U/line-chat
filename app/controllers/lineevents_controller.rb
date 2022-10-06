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
    logger.debug("callback")
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      error 400 do 'Bad Request' end
    end
    events = client.parse_events_from(body)
    events.each do |event|
      # if event.is_a?(Line::Bot::Event::Message)
      #   if event.type === Line::Bot::Event::MessageType::Text
      #     message = {
      #       type: 'text',
      #       text: event.message['text']
      #     }
      #     client.reply_message(event['replyToken'], message)
      #     logger.debug("good")
      #   end
      # end
      userId = event['source']['userId']  #userId取得
      p 'UserID: ' + userId # UserIdを確認
      
      if event.include?(:type)
        case event["type"]
        when "text" then
          message = {
            type: 'text',
            text: event.message['text']
          }
          client.reply_message(event['replyToken'], message)
        end
      end
    end
    render json: {status: 'SUCCESS'}, status: :ok
  end

end
