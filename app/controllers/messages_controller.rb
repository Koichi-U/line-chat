class MessagesController < ApplicationController
  def index
    @lineuser_id = params[:lineuser_id]
    @messages = Chat.where(lineuser_id: params[:lineuser_id])
    
    respond_to do |format|
      format.js
    end
  end
end