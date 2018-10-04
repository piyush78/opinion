class ApplicationController < ActionController::Base
  def callback
      logins = current_user.present? ? current_user.logins : {}
      case omniauth[:provider]
        when 'facebook'
          logins['graph.facebook.com']  = omniauth[:credentials][:token]
      
        else
          raise 'Unknown Provider'
      end
      cognito = Aws::CognitoIdentity::Client.new(region: 'us-west-2')
      resp = cognito.get_id(
          identity_pool_id: Rails.application.secrets.aws_cognito_identity_pool_id,
          logins: logins,
      )
      identity_id= resp.identity_id
      Rails.logger.debug "Cognito IdentityID: #{identity_id}"
      user = User.where(identity: identity_id).first_or_create
      if provider_class = Credential.provide_for(omniauth[:provider])
        provider_class.from_user_omniauth(
            user: user,
            omniauth: omniauth)
      else
        Rails.logger.error "Unsupported provider: #{omniauth[:provider]}"
      end
      session[:user_id] = user.id
      redirect_to root_url
    end
    def logout
      session.delete(:user_id)
      redirect_to root_url
    end
    private
    def omniauth
      request.env['omniauth.auth']
    end
  protect_from_forgery with: :exception

end

# def destroy
#   sign_out
#   redirect_to new_user_session_path
# end
