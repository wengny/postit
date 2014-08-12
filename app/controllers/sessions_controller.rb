class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.where(username: params[:username]).first # use first because it always returns array, 
    # alternative sytax to the above line is:
    # user = User.find_by(username: params[:username])

    if user && user.authenticate(params[:password])
      #binding.pry
      if user.two_factor_auth?
        session[:two_factor] = true
        user.generate_pin!
        redirect_to pin_path
      else
        login_user!(user)
      end
    else
      flash[:error] = "There is something wrong with your username or password."
      redirect_to login_path
    end
  end

  def destroy
    session[:user_id] = nil
    flash[:notice] = "You've logged out."
    redirect_to root_path
  end

  def pin 
    # This point is for both get and set methods,  
    # for get method, the controller default created a method for it to render template, for post, it need to define.
    access_denied if session[:two_factor].nil?

    if request.post?
      user = User.find_by pin: params[:pin]
      if user
        session[:two_factor] = nil
        user.remove_pin!
        login_user!(user)
      else
        flash[:error] = "Sorry, something is wrong with your pin number."
        redirect_to pin_path
      end
    end
  end

  private

  def login_user!(user)
    session[:user_id] = user.id
    flash[:notice] = "Welcome, you've logged in."
    redirect_to root_path
  end
end