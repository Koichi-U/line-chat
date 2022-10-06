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
      p event
      if event.is_a?(Line::Bot::Event::Message)
        p 'if'
        #イベントタイプで判別
        if event.type == "text"
          p 'if-iftext'
          message = {
            type: 'text',
            text: event.message['text']
          }
          response = client.reply_message(event['replyToken'], message)
          if response.code != 200
            p 'if-iftext-status'
            statusCode = response.code
            statusMessage = response.message
          end
          p 'else-else-else'
        end
        p 'else-else'
      elsif event.is_a?(Line::Bot::Event::Follow) or event.is_a?(Line::Bot::Event::Unfollow)
        #フォローまたはブロックの場合
        if event['type'] == "follow" or event['type'] == "unfollow"
          p 'if-elsiffollowunfollow'
          #userIdの取得
          userId = event['source']['userId']
          p userId
          p userId.class
          #Lineusersにレコードがない場合
          if event['type'] == "follow" and Lineuser.find_by(userid: userId).nil?
            p 'if-elsiffollowunfollow-ifnil'
            response = client.get_profile(userId.to_s)
            p response
            #now
            case response
            when Net::HTTPSuccess then
              contact = JSON.parse(response.body)
              displayName = contact['displayName']
              language = contact['language']
              pictureUrl = contact['pictureUrl']
              statusMessage = contact['statusMessage']
              
              #フォロー、ブロックのデータ分岐
              if event['type'] == "follow"
                p 'if-elsiffollowunfollow-ifnil-follow'
                active_follows = 1
                active = true
              elsif event['type'] == "unfollow"
                p 'if-elsiffollowunfollow-ifnil-unfollow'
                active_follows = 0
                active = false
              else
                p 'if-elsiffollowunfollow-ifnil-else'
                active_follows = 2
                active = false
              end
              
              #lineuser、followへの保存
              lineuser = Lineuser.new(
                displayname: displayName, 
                userid: userId, 
                language: language, 
                pictureurl: pictureUrl, 
                statusmessage: statusMessage,
                active: active
              )
              lineuser.follows.build(
                active: active_follows
              )
              
              if lineuser.save
                p "Register a line user"
              else
                p "Cannot register a line user"
              end
            else
              p 'if-elsiffollowunfollow-else'
              statusCode = response.code
              statusMessage = response.message
            end
          elsif !Lineuser.find_by(userid: userId).nil?
            p 'if-else'
            #Lineusersのデータ取得
            lineuser = Lineuser.find_by(userid: userId)
            
            #フォロー、ブロックの条件分岐
            if event['type'] == "follow"
              p 'if-else-follow'
              lineuser.update(active: true)
              follow.update(active: 1)
            elsif event['type'] == "unfollow"
              p 'if-else-unfollow'
              lineuser.update(active: false)
              follow.update(active: 0)
            end
            p 'else-else-else-else'
          end
          p 'else-else-else'
        end
        p 'else-else'
      end
      p 'else'
    end
    
    statusCode = statusCode.to_s ||= ''
    p 'Code:' + statusCode + '  message:' + statusMessage
    render status: statusCode, json: { status: statusCode, message: statusMessage }
  end
  
  def list
    @lineusers = Lineuser.all
  end
  
  def chat
    @chats = Chat.includes(:lineusers).where(lineusers: {userid: params[userid]})
    @chat = Chat.new
  end
  
  def create
    chat = Chat.new(chat_params)
    chat.lineusers_id = 1
    if chat.save
      redirect_to :action => "chat"
    else
      redirect_to :action => "list"
    end
  end
  
  private
  def chat_params
    params.require(:chat).permit(:message)
  end

end
