
class ChargesController < ApplicationController
skip_before_action  :verify_authenticity_token
  def new
  end

  def create
  # Amount in cents

    if (params[:email]!= "" && params[:stripeToken]!= "") && (session[:token] != "" || params[:accesstoken])

      @amount = 500
      dynamodb = Aws::DynamoDB::Client.new
      resp = dynamodb.get_item(:table_name => "Opi9_user", :key => {"email" => params[:email]})
      if resp.item
        response = dynamodb.get_item(:table_name => "Opi9_signin", :key => { "access_token" => (params[:accesstoken] || session[:token]) })
        if current_user = response['item']
          if current_user['expires_at']-Time.now.to_i > 0
            res = dynamodb.get_item(:table_name => "Opi9_user", :key => {"email" => current_user['email']})
            user = res['item']


           customer = Stripe::Customer.create(
              :email => params[:email],
              :card  => params[:stripeToken]
            )

            charge = Stripe::Charge.create(
              :customer    => customer.id,
              :amount      => @amount,
              :description => 'Rails Stripe customer',
              :currency    => 'usd'
            )
            if charge
              if user['connected_user'] == nil
                connected_user = [params[:email]]
              else
                if user['connected_user'].include? params[:email]
                  connected_user = user['connected_user']
                else
                  connected_user = user['connected_user'] + [params[:email]]
                end
              end
              if user != nil
                record = {
                  "uid" => user['uid'],
                  "firstname" => user['firstname'],
                  "lastname" => user['lastname'],
                  "gender" => user['gender'],
                  "phone" => user['phone'],
                  "email" => user['email'],
                  "password" => user['password'],
                  "usertypereg" => user['usertypereg'],
                  "connected_user" => connected_user
                  }
                dynamodb.put_item(:table_name => "Opi9_user", :item => record)
                response = dynamodb.get_item(:table_name => "Opi9_user", :key => { "email" => current_user['email'] })
                user = response['item']
                session[:connected_user]= user['connected_user']
              end
              payed = (@amount/100).to_s
              dynamodb = Aws::DynamoDB::Client.new
              user['email']
              resp = dynamodb.put_item({
                table_name: "Opi9_stripe_payment", # required
                item: {
                  "token" => params[:stripeToken], # value <Hash,Array,String,Numeric,Boolean,IO,Set,nil>
                  "connected_email" => params[:email],
                  "amount" => payed + "$",
                  "current_user" => user['email'],
                  "customer" => customer.id
                }
              })
              respond_to do |format|
                format.html {render new, notice:"successfully subscribed the user" }
                format.json {render json:{"subscribed_user" => user['connected_user'], "status" => "success"}}
              end
            else
              respond_to do |format|
                format.html {redirect_to users_path, notice:"stripe user creation failed" }
                format.json {render json:{"error" => "stripe user creation failed", "status" => "error"}}
              end
            end
          else
            respond_to do |format|
              format.html {redirect_to users_login_path, notice:"Access token Expired" }
              format.json {render json:{"error" => "Access token Expired", "status" => "error"}}
            end
          end
        else
          respond_to do |format|
            format.html {redirect_to users_login_path, notice:"Access token Invalid" }
            format.json {render json:{"error" => "Access token Invalid", "status" => "error"}}
          end
        end
      else
        respond_to do |format|
          format.html {redirect_to users_path, notice:"specified user is not available" }
          format.json {render json:{"error" => "specified user is not available", "status" => "error"}}
        end
      end
    else
      respond_to do |format|
        format.html {redirect_to users_path, notice:"invalid email/stripeToken" }
        format.json {render json:{"error" => "invalid email/stripeToken", "status" => "error"}}
      end
    end

  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to charges_path
  end
end
