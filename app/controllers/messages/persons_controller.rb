class Messages::PersonsController < ApplicationController
  def index
    @messages = Chat.where(lineuser_id: params[:lineuser_id])
    
    render partial: "messages", locals: { messages: @messages, lineuser_id: params[:lineuser_id] }
  end
end