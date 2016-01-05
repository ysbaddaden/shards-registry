class ApiController < Frost::Controller
  def authenticate_user!
    if token = params["api_key"]?
      @current_user = User.find_for_token_authentication(token)
    else
      head 401
    end
  rescue Frost::Record::RecordNotFound
    head 401
  end

  #def user_signed_in?
  #  !@current_user.nil?
  #end

  #def current_user
  #  @current_user.not_nil!
  #end

  def authorize!(resource)
    if authorized?(resource)
      true
    else
      head 401
      false
    end
  end

  def authorized?(resource)
    case resource
    when User then resource == current_user
    when Shard then resource.user_id == current_user.id
    end
  end

  def default_format
    "json"
  end
end
