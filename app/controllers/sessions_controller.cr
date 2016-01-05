class SessionsController < ApplicationController
  getter! :user

  def before_action
    authenticate_user! if action_name == "destroy"
  end

  def new
    @user = User.new
  end

  def create
    @user = User.find_for_database_authentication(user_params["name"] as String)

    if @user && user.valid_password?(user_params["password"] as String)
      login(user)
      redirect_to user_url(user)
    else
      render "new", status: 401
    end
  rescue Frost::Record::RecordNotFound
    render "new", status: 401
  end

  def destroy
    logout
    redirect_to shards_url
  end

  private def user_params
    params["user"] as Hash
  end
end
