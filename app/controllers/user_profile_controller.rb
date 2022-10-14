class UserProfileController < ApplicationController
  def index
    @user_profile = UserProfile.all
  end

  def show
    @user_profile = UserProfile.find(params[:id])
  end

  def new
    @user_profile = UserProfile.new
  end

  def create
    @user_profile =
      UserProfile.new(
        gov_id: "...",
        street_address_1: "...",
        street_address_2: "..."
      )

    if @user_profile.save
      redirect_to @user_profile
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @user_profile = UserProfile.find(params[:id])
  end

  def update
    @user_profile = UserProfile.find(params[:id])

    if @user_profile.update(user_profile_params)
      redirect_to @user_profile
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user_profile = UserProfile.find(params[:id])
    @user_profile.destroy

    redirect_to home_path, status: :see_other
  end

  private

  def user_profile_params
    params.require(:user_profile).permit(
      :gov_id,
      :street_address_1,
      :street_address_2
    )
  end
end
