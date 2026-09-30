class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: [ :show, :edit, :update ]

  def index
    @users = User.order(:name, :email)
  end

  def show
    @orders = @user.orders.order(created_at: :desc)
  end

  def edit; end

  def update
    @user.assign_attributes(user_params)
    @user.admin = params.require(:user).fetch(:admin, "0") == "1"

    if @user.save
      redirect_to admin_user_path(@user), notice: "Usuario actualizado correctamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email)
  end
end
