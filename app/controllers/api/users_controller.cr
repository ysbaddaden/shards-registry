require "base64"

module Api
  class UsersController < ApiController
    def before_action
      authenticate_user! unless %w(api_key create).includes?(action_name)
    end

    def api_key
      if auth = basic_authentication
        user = User.find_for_database_authentication(auth[0])

        if user.valid_password?(auth[1])
          render text: { api_key: user.api_key }.to_json
          return
        end
      end

      head 401
    rescue ex : Frost::Record::RecordNotFound
      head 401
    end

    def create
      user = user_params(User.new)

      if user.save
        head 201
      else
        render text: user.errors.to_json, status: 422
      end
    end

    def update
      user = User.find(params["id"])
      return unless authorize!(user)

      user_params(user)

      if user.save
        head 200
      else
        render text: user.errors.to_json, status: 422
      end
    end

    private def user_params(user)
      JSON.parse(request.body.to_s).each do |key, value|
        case key.as_s
        when "name" then user.name = value.as_s
        when "email" then user.email = value.as_s
        when "password" then user.password = value.as_s
        end
      end

      user
    end

    private def basic_authentication
      if header = request.headers["Authorization"]?
        if header.starts_with?("Basic ")
          Base64.decode_string(header[6 .. -1]).split(':')
        end
      end
    end
  end
end
