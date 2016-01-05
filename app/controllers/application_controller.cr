class UnauthorizedError < Exception
end

class Frost::Controller
  abstract def authenticate_user!

  def current_user
    raise UnauthorizedError.new unless user = current_user?
    user
  end

  def current_user?
    @current_user ||= if user_id = session["user_id"]?
                        User.find(user_id)
                      end
  end

  def user_signed_in?
    !!current_user?
  end

  def login(user)
    @current_user = user
    session["user_id"] = user.id
  end

  def logout
    @current_user = nil
    session.delete("user_id")
    #session.destroy
  end
end

class ApplicationController < Frost::Controller
  def authenticate_user!
    raise UnauthorizedError.new unless user_signed_in?
  end

  # TODO: render HTML error page
  def rescue_from(exception)
    case exception
    when Frost::Record::RecordNotFound
      head 404
    when UnauthorizedError
      redirect_to new_user_session_url
    else
      false
    end
  end
end
