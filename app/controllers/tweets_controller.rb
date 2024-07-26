class TweetsController < ApplicationController
  before_action :authenticate_user, only: [:create, :destroy]

  def index
    tweets = Tweet.order(created_at: :desc).includes(:user)
    render json: { 
      tweets: tweets.map do |tweet|
        {
          id: tweet.id,
          username: tweet.user.username,
          message: tweet.message
        }
      end
    }
  end

  def index_by_user
    user = User.find_by(username: params[:username])
    if user
      tweets = user.tweets
      render json: {
        tweets: tweets.map do |tweet|
          {
            id: tweet.id,
            username: user.username,
            message: tweet.message
          }
        end
      }
    else
      render json: { error: "User not found" }, status: :not_found
    end
  end

  def create
    tweet = @current_user.tweets.build(tweet_params)
    if tweet.save
      render json: { tweet: { username: @current_user.username, message: tweet.message } }, status: :created
    else
      render json: tweet.errors, status: :unprocessable_entity
    end
  end

  def destroy
    tweet = @current_user.tweets.find(params[:id])
    if tweet.destroy
      render json: { success: true }, status: :ok
    else
      render json: { error: "Not authenticated" }, status: :forbidden
    end
  end

  private

  def authenticate_user
    token = cookies.signed[:twitter_session_token]
    session = Session.find_by(token: token)
    @current_user = session&.user
    unless @current_user
      render json: { error: "Not authenticated" }, status: :unauthorized
    end
  end

  def tweet_params
    params.require(:tweet).permit(:message)
  end
end
