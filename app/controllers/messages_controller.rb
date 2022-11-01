class MessagesController < ApplicationController
  def index
    @lineuser_id = 1
    @messages = Chat.where(lineuser_id: params[:lineuser_id])
    
    respond_to do |format|
      format.js
    end
  end
end