class Messages::PersonsController < ApplicationController
  def index
    @lineuser_id = params[:lineuser_id]
    @messages = Chat.where(lineuser_id: params[:lineuser_id])
    
    respond_to do |format|
      # format.html { redirect_to :root }
      format.js
      # format.json { render json: {messages: @messages, lineuser_id: @lineuser_id } }
    end
    # render partial: 'lineevents/messages', locals: { messages: @messages, lineuser_id: @lineuser_id}
  end
end