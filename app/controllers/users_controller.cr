class UsersController < ApplicationController
  getter! :user, :shards, :versions

  def before_action
    authenticate_user! unless %w(show new create).includes?(action_name)
    authorize! if %w(edit update reset_api_key destroy).includes?(action_name)
  end

  def show
    @user = User.find_by({ name: params["id"] })
    @shards = user.shards.include_latest_version
  end

  def new
    @user = User.new
  end

  def edit
    @user = current_user
  end

  def create
    @user = user_params(User.new)

    if user.save
      login(user)
      redirect_to user_url(current_user)
    else
      render "new", status: 422
    end
  end

  def update
    @user = user_params(current_user)

    if user.save
      redirect_to user_url(current_user)
    else
      render "edit", status: 422
    end
  end

  def reset_api_key
    current_user.generate_api_key

    if current_user.save
      session["flash"] = { notice: "New API key generated" }.to_json
      redirect_to user_url(current_user)
    else
      render status: 422
    end
  end

  def destroy
    current_user.destroy
    redirect_to shards_url
  end

  private def authorize!
    head 401 unless current_user.name == params["id"]
  end

  private def user_params(user)
    (params["user"] as Hash).each do |key, value|
      case key
      when "name"
        user.name = value as String
      when "email"
        user.email = value as String
      when "password"
        password = value as String
        user.password = password unless password.blank?
      end
    end

    user
  end
end
