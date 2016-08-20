module Admin
  class UsersController < AdminController
    def show
      @user = User.find(params[:id])
    end

    def update
      @user = User.find(params[:id])
      @user.admin_updating_user = true
      @user.password = params[:password] if params[:password]
      if @user.save
        redirect_to edit_user_path(@user.id), :notice => "User has been updated"
      else
        redirect_to({:action => "show", :id => @user.id}, {:notice => "User could not be saved"})
      end
    end
  end
end