class Messages::PersonsController < ApplicationController
  def index
    @messages = Chat.where(lineuser_id: params[:lineuser_id])
    
    respond_to do |format|
      format.html { redirect_to :root }
      format.json { render json: @messages }
    end
  end
end