class SessionsController < ApplicationController
  def create
    user = User.find_by(username: params[:user][:username])
    if user&.authenticate(params[:user][:password])
      session = user.sessions.create
      cookies.permanent.signed[:twitter_session_token] = {
        value: session.token,
        httponly: true
      }
      render json: { success: true }, status: :created
    else
      render json: { error: "Invalid credentials" }, status: :unauthorized
    end
  end

  def authenticated
    token = cookies.signed[:twitter_session_token]
    Rails.logger.debug "Checking session with token: #{token}"
    session = Session.find_by(token: token)
    if session
      render json: { authenticated: true, username: session.user.username }, status: :ok
    else
      render json: { authenticated: false }, status: :unauthorized
    end
  end

  def destroy
    token = cookies.signed[:twitter_session_token]
    Rails.logger.debug "Session token from cookies: #{token}"
    session = Session.find_by(token: token)
    if session
      session.destroy
      cookies.delete(:twitter_session_token, path: '/')
      cookies[:twitter_session_token] = { value: nil, expires: 1.minute.ago, path: '/' }
      Rails.logger.debug "Session destroyed and cookie deleted"
      render json: { success: true, message: "Logged out" }, status: :ok
    else
      Rails.logger.debug "No session found with the provided token"
      render json: { error: "Not logged in" }, status: :unprocessable_entity
    end
  end
end
