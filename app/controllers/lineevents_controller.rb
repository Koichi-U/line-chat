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
    
    statusCode = 200
    statusMessage = 'OK'
    
    events = client.parse_events_from(body)
    events.each do |event|
      if event.is_a?(Line::Bot::Event::Message)
        #イベントタイプで判別
        if event.type == "text"
          message = {
            type: 'text',
            text: event.message['text']
          }
          response = client.reply_message(event['replyToken'], message)
          if response.code != 200
            statusCode = response.code
            statusMessage = response.message
          end
        
        #フォローまたはブロックの場合
        elsif event.type == "follow" or event.type == "unfollow"
          #userIdの取得
          userId = event['source']['userId']
          #Lineusersにレコードがない場合
          if Lineusers.find_by(userid: userId).nil?
            response = client.get_profile(userId)
            case response
            when Net::HTTPSuccess then
              contact = JSON.parse(response.body)
              displayName = contact['displayName']
              language = contact['language']
              pictureUrl = contact['pictureUrl']
              statusMessage = contact['statusMessage']
              
              #フォロー、ブロックのデータ分岐
              if event.type == "follow"
                active_follows = 1
                active = true
              elsif event.type == "unfollow"
                active_follows = 0
                active = false
              else
                active_follows =2
                active = false
              end
              
              #lineusers、followsへの保存
              lineusers = Lineusers.new(
                displayName: displayName, 
                userid: userId, 
                language: language, 
                pictureurl: pictureUrl, 
                statusmessage: statusMessage,
                active: active
              )
              lineusers.follows.build(
                active: active_follows
              )
              
              if lineusers.save
                p "Register a line user"
              else
                p "Cannot register a line user"
              end
            else
              statusCode = response.code
              statusMessage = response.message
            end
          else
            #Lineusersのデータ取得
            lineuser = Lineusers.find_by(userid: userId)
            
            #フォロー、ブロックの条件分岐
            if event.type == "follow"
              lineuser.update(active: true)
              follows.update(active: 1)
            elsif event.type == "unfollow"
              lineuser.update(active: false)
              follows.update(active: 0)
            end
            
          end
        end
      end
    end
    p statusCode.class
    p statusMessage.class
    # p 'Code:' + statusCode + '  message:' + statusMessage
    render status: status, json: { status: statusCode, message: statusMessage }
  end

end
