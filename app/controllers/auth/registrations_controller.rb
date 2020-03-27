class Auth::RegistrationsController < ::Devise::RegistrationsController

  def edit
    session['homes.step'] = nil
  end

  def update
    @user = current_user
    redirect = (session['homes.step'] == 1) ? step2_homes_path : edit_user_registration_path
    redirect = root_path if current_user.is_admin? || current_company && current_company.is_jvp?

    respond_to do |format|
      if @user.update_without_password(resource_params)
        sign_in @user, :bypass => true
        format.html{ 
          if @user.pending_reconfirmation?
            set_flash_message :notice, :update_needs_confirmation
          else
            set_flash_message :notice, :updated
          end
          redirect_to redirect
        }
        format.js#
      else
        format.html{ render action: :edit }
        format.js#
      end
    end
  end

  protected
    def resource_params
      a = [:first_name, :last_name, :current_password, :password, :password_confirmation, :avatar, :locale, :accept_terms]
      params.require(:user).permit(*a)
    end
end