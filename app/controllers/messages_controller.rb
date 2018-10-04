require 'securerandom'
class MessagesController < ApplicationController
  skip_before_action  :verify_authenticity_token

  def search
    if session[:token] != nil || params[:accesstoken] != nil
      @dynamodb = Aws::DynamoDB::Client.new
      resp = @dynamodb.get_item(:table_name => "Opi9_signin", :key => {"access_token" => (@accesstoken || session[:token] )})
      current_user = resp['item']
      current_user['expires_at'].to_i-Time.now.to_i
      if current_user['expires_at'].to_i-Time.now.to_i > 0
        if params[:search]==nil || params[:search]==""
          respond_to do|format|
            format.json {render json:{"searched user" => @users, "status" => "failure"}}
            format.html {render :search}
          end
        else
          @search = params[:search]
          dynamodb = Aws::DynamoDB::Client.new
          response1 = dynamodb.get_item(:table_name => "Opi9_user", :key => {"email" => @search})
          @users =response1.item
          if @users
            @users.delete("password")
            @users.delete("connected_user")
            @users.delete("usertypereg")
          end
          respond_to do |format|
            format.json {render json:{"searched user" => @users, "status" => "success"}}
            format.html {render :search}
          end
        end
      else
        respond_to do |format|
          format.json {render json:{"searched user" => "Accesstoken Invalid/Expired", "status" => "failure"}}
          format.html {render :search}
        end
      end
    else
      redirect_to root_path
    end
  end


  def conversations
    if (session[:token] != nil ||  params[:access_token] != nil )
      dynamodb = Aws::DynamoDB::Client.new
      get_user = dynamodb.get_item(:table_name => "Opi9_signin", :key => {"access_token" => session[:token]})
      if get_user.item["expires_at"]
        if (get_user.item["expires_at"]-Time.now.to_i) > 0
          @user = get_user.item["email"]
          response = dynamodb.scan(:table_name => "Opi9_message")
          @messages = response.items
        else
          respond_to do |format|
            format.html {redirect_to users_login_path, :notice => "Invalid/Expired Access Token"}
            format.json {render json:{"error" => "Invalid/Expired Access Token", "status" => "error" }}
          end
        end
      else
        flash[:notice] ="Invalid/Expired Access Token"
      end
    else
      redirect_to users_login_path
    end
  end

  def sentconversations
    if session[:token] != nil
      dynamodb = Aws::DynamoDB::Client.new
      response = dynamodb.scan(:table_name => "Opi9_message")
      @messages = response.items
    else
      redirect_to users_login_path
    end
  end

  def show
    if session[:token] != nil
      @message_id=params[:id]
      dynamodb = Aws::DynamoDB::Client.new
      message = dynamodb.get_item(:table_name => "Opi9_message", :key => { "message_id" => @message_id })
      @message = message.item
      comments = dynamodb.scan(:table_name => "Opi9_comments")
      @comments = comments.items
      response = dynamodb.get_item(:table_name => "Opi9_signin", :key => {"access_token" => session[:token] })
      @user = response.item['email']
    else
      redirect_to root_path
    end
  end

  def sentshow
    if session[:token] != nil
      @message_id=params[:id]
      dynamodb = Aws::DynamoDB::Client.new
      message = dynamodb.get_item(:table_name => "Opi9_message", :key => { "message_id" => @message_id })
      @message = message.item
      comments = dynamodb.scan(:table_name => "Opi9_comments")
      @comments = comments.items
    else
      redirect_to root_path
    end
  end

  def new
    @email = params[:email]
  end

  def create
    if params[:email] != "" && params[:title] != "" && params[:description] != "" && (params[:accesstoken] || session[:token]) != ""
      @message_id = SecureRandom.uuid
      dynamodb = Aws::DynamoDB::Client.new
      response = dynamodb.get_item(:table_name => "Opi9_user", :key => { "email" => params[:email] })
      if response.item
        giver = response['item']
        response = dynamodb.get_item(:table_name => "Opi9_signin", :key => { "access_token" => (session[:token] || params[:accesstoken]) })
        if response.item
          subscriber = response.item
          if (subscriber['expires_at'] - Time.now.to_i) > 0
            response = dynamodb.get_item(:table_name => "Opi9_user", :key => { "email" => subscriber['email'] })
            seeker = response['item']
            record = {
              "message_id" => @message_id,
              "message_title" => params[:title],
              "message_description" => params[:description],
              "seekeremail" => subscriber['email'],
              "giveremail" => params[:email],
              "givername" => giver['firstname'] + " " +  giver['lastname'],
              "seekername" => seeker['firstname'] + " " + seeker['lastname'],
              "timestamp" => Time.now.to_i
              }
            update_id=dynamodb.put_item(:table_name => "Opi9_message", :item => record)
            mail = UserMailer.sendMail(params[:email],subscriber['email']).deliver
            if update_id
              respond_to do |format|
                format.html { redirect_to messages_show_path(:id => @message_id), :notice => "Thanks! We've posted a new Opinion" }
                format.json {render json:{"message" => record, "status" => "success" } }
              end
            end
          else
            respond_to do |format|
              format.html { redirect_to users_login_path, :notice => "accesstoken expired" }
              format.json {render json:{"error" => "accesstoken expired", "status" => "error" } }
            end
          end
        else
          respond_to do |format|
            format.html { redirect_to messages_path, :notice => "invalid accesstoken" }
            format.json {render json:{"error" => "invalid accesstoken", "status" => "error" } }
          end
        end
      else
        respond_to do |format|
          format.html { redirect_to messages_path, :notice => "invalid email" }
          format.json {render json:{"error" => "invalid email", "status" => "error" } }
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to messages_path, :notice => "invalid parameters" }
        format.json {render json:{"error" => "invalid parameters", "status" => "error" } }
      end
    end
  end

  def edit
    @message_id = params[:id]
    dynamodb = Aws::DynamoDB::Client.new
    response = dynamodb.get_item(:table_name => "Opi9_message", :key => {"message_id" => @message_id})
    @message = response.item
  end

  def update
    dynamodb = Aws::DynamoDB::Client.new
    title_update = dynamodb.update_item({table_name: 'Opi9_message', key: {'message_id' => params[:message_id]}, update_expression: 'SET message_title = :title', expression_attribute_values: {':title' => params[:title]}})
    desciption_update = dynamodb.update_item({table_name: 'Opi9_message', key: {'message_id' => params[:message_id]}, update_expression: 'SET message_description = :title', expression_attribute_values: {':title' => params[:description]}})
    if title_update && desciption_update
      flash[:notice] = "your Opinion title and description updated..."
      redirect_to messages_show_path(:id => params[:message_id])
    else
      flash[:notice] = "error in updating"
      redirect to messages_edit_path
    end
  end

  def delete
    @message_id = params[:id]
    dynamodb = Aws::DynamoDB::Client.new
    dynamodb.delete_item({table_name: "Opi9_message",key: {"message_id" => @message_id}})
    res= dynamodb.scan(table_name: "Opi9_comments")
    @comments = res.items
    if @comments
      @comments.each do |comment|
        if comment['message_id'] == @message_id
          dynamodb.delete_item(table_name: "Opi9_comments", key: {"comment_id" => comment['comment_id']})
        end
      end
    end
    flash[:notice] = "Message deleted successfully"
    redirect_to conversations_path
  end

  def deletesent
    @message_id = params[:id]
    dynamodb = Aws::DynamoDB::Client.new
    dynamodb.delete_item({table_name: "Opi9_message",key: {"message_id" => @message_id}})
    res= dynamodb.scan(table_name: "Opi9_comments")
    @comments = res.items
    if @comments
      @comments.each do |comment|
        if comment['message_id'] == @message_id
          dynamodb.delete_item(table_name: "Opi9_comments", key: {"comment_id" => comment['comment_id']})
        end
      end
    end
    flash[:notice] = "Message deleted successfully"
    redirect_to sentconversations_path
  end

  private

  def message_params
    params.require(:message).permit(:title,:description)
  end
end
