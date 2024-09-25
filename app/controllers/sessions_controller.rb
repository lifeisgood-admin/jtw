class SessionsController < ApplicationController  
  # layout 'for_public'
  
  def new
  end

  def create
    user = User.find_by(mail: session_params[:mail])

    if user&.authenticate(session_params[:password])
      session[:user_id] = user.id
      redirect_to '/admin'
    else
      render :new
    end
  end

  def destroy
    reset_session
    redirect_to login_path
  end

  private

  def session_params
    params.require(:session).permit(:mail, :password)
  end

end