# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    def decrypt_session_cookie(cookie, key)
      cookie = CGI::unescape(cookie)

      # Default values for Rails apps
      key_iter_num = 1000
      key_size     = 64
      salt         = "encrypted cookie"
      signed_salt  = "signed encrypted cookie"

      key_generator = ActiveSupport::KeyGenerator.new(key, iterations: key_iter_num)
      secret = key_generator.generate_key(salt)
      sign_secret = key_generator.generate_key(signed_salt)

      encryptor = ActiveSupport::MessageEncryptor.new(secret, sign_secret, serializer: JSON)
      encryptor.decrypt_and_verify(cookie)
    end

    def session_cookie
      cookies[Rails.application.config.session_options[:key]]
    end

    def session
      decrypt_session_cookie(session_cookie, Rails.application.secrets.secret_key_base)
    end

    identified_by :current_user

    def connect
      if self.current_user = User.find_by(id: session["warden.user.user.key"][0][0])
        Rails.logger.info "Connected as #{self.current_user.email}"
      else
        reject_unauthorized_connection
      end
    end
  end
end
