require 'securerandom'
class CommentsController < ApplicationController

  def show
  end

  def create
    @comment_id = SecureRandom.uuid
    dynamodb = Aws::DynamoDB::Client.new
    response = dynamodb.get_item(:table_name => "Opi9_user", :key => {"email" => session[:user]})
    @user = response.item
    record = {
      "comment_id" => @comment_id,
      "message_id" => params[:id],
      "comment_description" => params[:description],
      "email" => session[:user],
      "name" => @user['firstname'] + " " + @user['lastname'],
      "timestamp" => Time.now.to_i
    }
    update_id=dynamodb.put_item(:table_name => "Opi9_comments", :item => record)
    if update_id
      flash[:notice] = "Thanks! We've given a reply to Opinion."
      redirect_to messages_show_path(:id => params[:id])
    end
  end

  def edit
    @comment_id = params[:id]
    dynamodb = Aws::DynamoDB::Client.new
    response = dynamodb.get_item(:table_name => "Opi9_comments", :key => {"comment_id" => @comment_id})
    @comment = response.item
  end

   def update
    dynamodb = Aws::DynamoDB::Client.new
    reply_update = dynamodb.update_item({table_name: 'Opi9_comments', key: {'comment_id' => params[:comment_id]}, update_expression: 'SET comment_description = :title', expression_attribute_values: {':title' => params[:description]}})
    if reply_update
      flash[:notice] = "your Reply is updated..."
      response = dynamodb.get_item(:table_name => "Opi9_comments", :key => {"comment_id" => params[:comment_id]})
      comment = response.item
      redirect_to messages_show_path(:id => comment['message_id'])
    else
      flash[:notice] = "error in updating"
      redirect to messages_edit_path
    end
  end


  def delete
    @comment_id = params[:id]
    dynamodb = Aws::DynamoDB::Client.new
    res = dynamodb.get_item({table_name: "Opi9_comments",key: {"comment_id" => @comment_id }})
    @comment = res.item
    response = dynamodb.delete_item({table_name: "Opi9_comments",key: {"comment_id" => @comment_id }})
    if response
        redirect_to messages_show_path(:id => @comment['message_id'])
    else
        flash[:notice] = "error in deleting..."
        redirect_to messages_show_path(:id => @comment['message_id'])
    end
  end

  private
  def comment_params
    params.require(:message).permit(:id,:description)
  end
end
