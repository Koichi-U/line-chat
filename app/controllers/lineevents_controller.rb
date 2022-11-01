class LineeventsController < ApplicationController
  before_action :authenticate_user!, except: [:client, :callback]
  WEBHOOK_URL = ENV["WEBHOOK_URL"]
  
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
          
          lineuser = Lineuser.find_by(userid: event['source']['userId'])
          p lineuser
          
          notifier.post text: event.message['text'], username: lineuser.displayname, icon_url: lineuser.pictureurl, channel: "#line-chat-bot"
          
          chat = Chat.new(
            message: event.message['text'],
            lineuser_id: lineuser.id
          )
          
          if chat.save
            p "Save a message"
            lineuser.update(
              lastmessage: event.message['text'],
              lastmessagetime: chat.created_at,
              read: false,
              readcount: lineuser.readcount+1
            )
          else
            p "Cannot save a message"
          end
          
          p 'else-else-else'
        end
        p 'else-else'
      elsif event.is_a?(Line::Bot::Event::Follow) or event.is_a?(Line::Bot::Event::Unfollow)
        eventFlag = ""
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
                active: active,
                lastmessage: "",
                lastmessagetime: ""
              )
              lineuser.follows.build(
                active: active_follows
              )
              
              if lineuser.save
                p "Register a line user"
                lineuser.update(lastmessagetime: lineuser.created_at)
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
            follow = Follow.new(lineuser_id: userId)
            
            #フォロー、ブロックの条件分岐
            if event['type'] == "follow"
              p 'if-else-follow'
              lineuser.update(active: true)
              follow.active = 1
              eventFlag = "follow"
            elsif event['type'] == "unfollow"
              p 'if-else-unfollow'
              lineuser.update(active: false)
              follow.active = 0
              eventFlag = "unfollow"
            end
            
            if follow.save
              p "good follow/unfollow"
            end
            p 'else-else-else-else'
          end
          p 'else-else-else'
        end
        p 'else-else'
        notifier.post text: eventFlag, username: lineuser.displayname, icon_url: lineuser.pictureurl, channel: "#line-chat-bot"
      end
      p 'else'
    end
    
    statusCode = statusCode.to_s ||= ''
    p 'Code:' + statusCode + '  message:' + statusMessage
    render status: statusCode, json: { status: statusCode, message: statusMessage }
  end
  
  def list
    @lineusers = Lineuser.all.order(lastmessagetime: "DESC")
    @messages = nil
    @lineuser_id = nil
  end
  
  def chat
    p Chat.all
    @chats = Chat.includes(:lineuser).where(lineuser: { userid: params[:userid]})
    p @chats
    @chat = Chat.new
  end
  
  def messagecreate
    statusCode = 200
    statusMessage = 'OK'
    message = {
      type: 'text',
      text: params[:chat][:message]
    }
    
    p params[:chat][:message]
    p params[:chat][:lineuser_id]
    
    lineuser = Lineuser.find(params[:chat][:lineuser_id])
    p lineuser
    
    response = client.push_message(params[:chat][:lineuser_id], message)
    p response.code
    if response.code != "200"
      p 'if-iftext-status'
      statusCode = response.code
      statusMessage = response.message
      
      statusCode = statusCode.to_s ||= ''
      p 'Code:' + statusCode + '  message:' + statusMessage
      redirect_back(fallback_location: root_path)
    else
      chat = Chat.new(chat_params)
      chat.lineuser_id = lineuser.id
      chat.user_id = current_user.id
      p chat
      if chat.save
        p chat.message
        p chat.created_at
        lineuser.update(
          lastmessage: chat.message,
          lastmessagetime: chat.created_at,
          read: true,
          readcount: lineuser.readcount+1
        )
        redirect_back(fallback_location: root_path)
      else
        p chat.save!
        redirect_to :action => "list"
      end
      
      statusCode = statusCode.to_s ||= ''
      p 'Code:' + statusCode + '  message:' + statusMessage
    end
    
    
  end
  
  private
  
    def chat_params
      params.require(:chat).permit(:message, :lineuser_id)
    end
    
    def notifier
      Slack::Notifier.new WEBHOOK_URL
    end

end
