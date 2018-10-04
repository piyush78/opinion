class ChatController < ApplicationController

  def show
  end

  def new
    chating_user = params[:email]
    current_user = session[:user]
    channel = params[:email]+session[:user]
  end

  def create
    receiver = params[:receiver]
    message = params[:message]
    dynamodb = AWS::DynamoDB::Client.new
    resp = dynamodb.get_item(:table_name => "Opi9_signin", :key => {"access_token" => (params[:access_token] || session[:token])})
    sender = resp.item['email']
    p channel1 = receiver_sender
    p channel2 = sender_receiver
    res = dynamodb.scan(:table_name => "Opi9_chat")
  #   if res.item['channel'].include? channel1 || res.item['channel'].include? channel2
  #
  #   else
  #     dynamodb.put_item(:table_name => "Opi9_chat" , item =>{
  #       "channel" => channel1,
  #       "created_at" => Time.now.to_i,
  #       "receiver" => receiver,
  #       "sender" => sender
  #       } )
  # end
end
end
