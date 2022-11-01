class Messages::PersonsController < ApplicationController
  def index
    @lineuser_id = params[:lineuser_id]
    @messages = Chat.where(lineuser_id: params[:lineuser_id])
  end
end