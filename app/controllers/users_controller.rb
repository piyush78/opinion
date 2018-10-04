require 'securerandom'

class UsersController < ApplicationController
  skip_before_action  :verify_authenticity_token

  def newuser
  end


  def index
    if session[:token] != nil || params[:accesstoken] != nil
      @dynamodb = Aws::DynamoDB::Client.new
      resp = @dynamodb.get_item(:table_name => "Opi9_signin", :key => {"access_token" => (params[:accesstoken] || session[:token] )})
      current_user = resp['item']
      if current_user['expires_at']-Time.now.to_i > 0
        response = @dynamodb.scan(:table_name => "Opi9_user" )
        @users =response.items
        resp = @dynamodb.get_item(:table_name => "Opi9_user", :key => {"email" => current_user['email']})
        connected_users = resp.item['connected_user']
        if connected_users
          @listusers = []
          @users.each do | user |
            if user['email'] != current_user['email']
              if connected_users.include?(user['email'])
                @user =  [
                  "firstname" => user["firstname"],
                  "lastname" => user["lastname"],
                  "phone" => user["phone"],
                  "email" => user["email"],
                  "gender" => user["gender"],
                  "usertypereg" => user["usertypereg"],
                  "uid" => user["uid"],
                  "isSubscribed" => "yes"
                  ]
              else
                @user =  [
                  "firstname" => user["firstname"],
                  "lastname" => user["lastname"],
                  "phone" => user["phone"],
                  "email" => user["email"],
                  "gender" => user["gender"],
                  "usertypereg" => user["usertypereg"],
                  "uid" => user["uid"],
                  "isSubscribed" => "no"
                ]
              end
            else
              @user = []
             end
            @listusers= @listusers + @user
          end
          respond_to do |format|
            format.json {render json: {"users" => @listusers , "status" => "success"}}
            format.html {render :index}
          end
        else
          @listusers = []
          @users.each do | user |
            @user =  [
              "firstname" => user["firstname"],
              "lastname" => user["lastname"],
              "phone" => user["phone"],
              "email" => user["email"],
              "gender" => user["gender"],
              "usertypereg" => user["usertypereg"],
              "uid" => user["uid"],
              "isSubscribed" => "no"
            ]
            @listusers= @listusers + @user
          end
          respond_to do |format|
            format.json {render json: {"users" => @listusers , "status" => "success"}}
            format.html {render :index}
          end
        end
      else
        respond_to do |format|
          format.html {redirect_to users_login_path, :notice => "Accesstoken Invalid/Expired"}
          format.json {render json:{"error" => "Accesstoken Invalid/Expired", "status" => "error" }}
        end
      end
    else
      respond_to do |format|
        format.html {redirect_to users_login_path, :notice => "Please Specify your accesstoken"}
        format.json {render json:{"error" => "Please Specify your accesstoken", "status" => "error" }}
      end
    end
  end



  def googlelogin
    if request.env["omniauth.auth"].provider == "google_oauth2"
      cognitoidentity = Aws::CognitoIdentity::Client.new
      resp = cognitoidentity.get_open_id_token_for_developer_identity({identity_pool_id: "us-west-2:184cb0b6-f912-46c3-a174-5f58156dfdf9",
      logins: {
        "accounts.google.com" => request.env["omniauth.auth"].extra.id_token,
        },
        })
        @record = {
          "uid" => request.env["omniauth.auth"].uid,
          "firstname" => request.env["omniauth.auth"].info.first_name,
          "lastname" => request.env["omniauth.auth"].info.last_name,
          "email" => request.env["omniauth.auth"].extra.raw_info.email,
          "password" => "xxxxxx",
          "phone" => "xxxxxxxxx",
          "usertypereg" => "yes",
          "gender" => request.env["omniauth.auth"].extra.raw_info.gender
        }
    else
      if request.env["omniauth.auth"].provider == "facebook"
        cognitoidentity = Aws::CognitoIdentity::Client.new
        resp = cognitoidentity.get_open_id_token_for_developer_identity({
          identity_pool_id: 'us-west-2:xxxxxx',
          logins: {
            'graph.facebook.com' => request.env["omniauth.auth"].credentials.token
          },
          })
          name = (request.env["omniauth.auth"].info.name).split
          @record = {
            "uid" => request.env["omniauth.auth"].uid,
            "firstname" => name[0],
            "lastname" => name[1],
            "email" => request.env["omniauth.auth"].extra.raw_info.email,
            "password" => "xxxxxx",
            "phone" => "xxxxxxxxx",
            "usertypereg" => "yes",
            "gender" => request.env["omniauth.auth"].extra.raw_info.gender
          }
      end
    end
      # resp.token
      # resp.identity_id
      sts = Aws::STS::Client.new
      @response = sts.get_session_token({
        duration_seconds: 3600,
        })
      dynamodb = Aws::DynamoDB::Client.new
      record = {
        "provider" => request.env["omniauth.auth"].provider,
        "uid" => request.env["omniauth.auth"].uid,
        "name" => request.env["omniauth.auth"].info.name,
        "access_key_id" => @response.credentials.access_key_id ,
        "secret_access_key" => @response.credentials.secret_access_key,
        "access_token" => @response.credentials.session_token,
        "expires_at" => @response.credentials.expiration.to_i,
        "email" => request.env["omniauth.auth"].extra.raw_info.email
        }
      insert_user = dynamodb.put_item(:table_name => "Opi9_signin", :item => record)
      session[:user] = request.env["omniauth.auth"].extra.raw_info.email
      response = dynamodb.get_item(:table_name => "Opi9_user", :key => {:email => session[:user] })
      if response.item
        session[:connected_user] = response.item['connected_user']
      else
        dynamodb.put_item(:table_name => "Opi9_user", :item =>@record)
        session[:connected_user] = ""
      end
      session[:token] = @response.credentials.session_token
      redirect_to users_path
  end

  def signup
    respond_to do |format|
      if (params[:email] =~ /^(([A-Za-z0-9]*\.+*_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\+)|([A-Za-z0-9]+\+))*[A-Z‌​a-z0-9]+@{1}((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,4}$/i)
        if params[:password] == params[:password_confirmation]
          if params[:phone].length == 10
            dynamodb = Aws::DynamoDB::Client.new
            response = dynamodb.get_item(:table_name => "Opi9_user", :key => { "email" => params[:email]})
            user = response['item']
            @uid = SecureRandom.uuid

            # p cipher = OpenSSL::Cipher::AES.new(128, :CBC)
            # p cipher.encrypt
            # p key = cipher.random_key
            # p iv = cipher.random_iv
            #
            # p encrypted = cipher.update(password) + cipher.final
            cipher = Gibberish::AES::CBC.new(@uid)
            p password = cipher.encrypt(params[:password])
            if user == nil
              record = {
                "uid" => @uid,
                "firstname" => params[:firstname],
                "lastname" => params[:lastname],
                "email" => params[:email],
                "password" => password,
                "phone" => params[:phone],
                "usertypereg" => params[:usertypereg],
                "gender" => params[:gender]
              }
              dynamodb.put_item(:table_name => "Opi9_user", :item => record)
              # cognitoidentity = Aws::CognitoIdentity::Client.new()
              # resp = cognitoidentity.get_id({identity_pool_id: "us-west-2:184cb0b6-f912-46c3-a174-5f58156dfdf9",})
              sts = Aws::STS::Client.new()
              response = sts.get_session_token({
                duration_seconds: 3600,
              })
              dynamodb = Aws::DynamoDB::Client.new
              record = {
                "provider" => "Custom Login",
                "uid" => @uid,
                "name" => params['firstname'] + " " + params['lastname'],
                "access_key_id" => response.credentials.access_key_id ,
                "secret_access_key" => response.credentials.secret_access_key,
                "access_token" => response.credentials.session_token,
                "expires_at" => response.credentials.expiration.to_i,
                "email" => params[:email]
              }
              session[:user] = params[:email]
              insert_user = dynamodb.put_item(:table_name => "Opi9_signin", :item => record)
              session[:token] = response.credentials.session_token
              session[:connected_user] = "";
              format.html {redirect_to users_path , notice: "User created"}
              format.json {render json:{"accesstoken" => response.credentials.session_token,"user" => record, "status" => "success" }}
            else
              format.html {redirect_to users_newuser_path , notice: "Email already exists"}
              format.json {render json: {"error" => "email already exist", "status" => "error"}}
            end
          else
            format.html {redirect_to users_newuser_path , notice: "Enter 10 digits phone number"}
            format.json {render json: {"error" => "Enter 10 digits phone number", "status" => "error"}}
          end
        else
          format.html {redirect_to users_newuser_path , notice: "Password and Password confirmation Fields not matched"}
          format.json {render json: {"error" => "Password and Password confirmation Fields not matched", "status" => "error"}}
        end
      else
        format.html {redirect_to users_newuser_path , notice: "Enter a valid EmailId"}
        format.json {render json: {"error" => "Enter a valid EmailId", "status" => "error"}}
      end
    end
  end

  def login
  end

  def signin
        dynamodb = Aws::DynamoDB::Client.new
        response = dynamodb.get_item(:table_name => "Opi9_user", :key => { "email" => params[:email] })
        user = response['item']
        if user == nil
          respond_to do |format|
            format.html {redirect_to users_newuser_path , notice: "Sorry! you are not a member of this. Please signup to see this... "}
            format.json {render json: {"error" => "login failed","status"=> "invalid user"}}
            # flash[:notice] = "Sorry! you are not a member of this. Please signup to see this... "
            # redirect_to "users_newuser_path"
          end
        else
          respond_to do |format|
            if user['email'] == params[:email]
              # p decipher = OpenSSL::Cipher::AES.new(128, :CBC)
              # p decipher.decrypt
              # p decipher.key = user['key']
              # p decipher.iv = user['iv']
              #
              # p plain = decipher.update(user['password']) + decipher.final
              # if plain == params[:password]
              cipher = Gibberish::AES::CBC.new(user['uid'])
              password = cipher.decrypt(user['password'])
              if password == params[:password]
                # cognitoidentity = Aws::CognitoIdentity::Client.new()
                # resp = cognitoidentity.get_id({identity_pool_id: "us-west-2:184cb0b6-f912-46c3-a174-5f58156dfdf9",})
                sts = Aws::STS::Client.new()
                response = sts.get_session_token({
                  duration_seconds: 3600,
                  })
                dynamodb = Aws::DynamoDB::Client.new
                record = {
                  "provider" => "Custom Login",
                  "uid" => user['uid'],
                  "name" => user['firstname'] + " " + user['lastname'],
                  "access_key_id" => response.credentials.access_key_id ,
                  "secret_access_key" => response.credentials.secret_access_key,
                  "access_token" => response.credentials.session_token,
                  "expires_at" => response.credentials.expiration.to_i,
                  "email" => params[:email]
                  }
                session[:user] = params[:email]
                insert_user = dynamodb.put_item(:table_name => "Opi9_signin", :item => record)
                session[:token] = response.credentials.session_token
                session[:connected_user] = user['connected_user']

                format.html {redirect_to users_path, notice: "sucessfully logged in "}
                format.json {render json: {"accesstoken" => response.credentials.session_token, "user" => user, "status" => "success"}}
              else
                format.html {redirect_to users_login_path , notice: "invalid password!.. "}
                format.json {render json: {"error" => "login failed","status" => "invalid password"}}
              end
            else
              format.html {redirect_to users_newuser_path , notice: "invalid email!..  "}
              format.json {render json: {"error" => "login failed","status" => "invalid email"}}
            end
          end
        end
  end

  def signout
    session[:token] = nil
    session[:connected_user] = nil
    session[:user] = nil
    redirect_to root_path
  end

  def changepassword
  end

  def resetpassword
  end

  def forgetpassword
    dynamodb = Aws::DynamoDB::Client.new
    response = dynamodb.get_item(:table_name => "Opi9_user", :key => { "email" => params[:email] })
    user = response['item']
    if user != nil
      if params[:password]
        cipher = Gibberish::AES::CBC.new(user['uid'])
        password = cipher.encrypt(params[:password])
        dynamodb.update_item(:table_name => "Opi9_user", :key => {"email" => params[:email]}, :attribute_updates => { "password" => {:value => password, :action => "PUT"}})
        flash[:notice] = "Thanks! We've updated your password."
        redirect_to root_path
      else
        UserMailer.forgotPassword(params[:email]).deliver
        flash[:notice] = "email sent with url to Reset password"
        redirect_to users_changepassword_path
      end
    else
      flash[:notice] = "enter a valid email!.."
      redirect_to users_changepassword_path
    end
  end

  def subscribe
    @user = params[:email]
  end

  private
  def user_params
    params.require(:user).permit(:firstname, :lastname, :email, :password, :phone, :gender, :usertypereg)
  end
end
