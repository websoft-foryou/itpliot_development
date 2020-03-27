class Widgets::V1::RegistrationsController < Widgets::V1::MainController
  REGISTER_SECRETS = [
      "3j73Bcan7JkfIqRnAizJeRAk",
      "iIhtJ2Hmm9EVntwp5n9lptjv",
      "NBPxmnPzwh0UlXsJgc7qM0TJ",
      "0NHXed3qXQJvrJNt4VDeBXuH",
      "FDtzmYIWUP4mBgNuMYIbmA5O"
  ]

  def new
    @user = User.new()
    response.headers['X-FRAME-OPTIONS'] = 'ALLOWALL'
  end

  def create
    #head(:unauthorized) and return unless verify_recaptcha

    # Check token

    @valid_tokens = []
    REGISTER_SECRETS.each do |secret|
      sha1 = Digest::SHA1.new               # =>#<Digest::SHA1>
      sha1 << "#{secret}-#{params[:user][:role_type]}-#{params[:invitation_parent_company_id]}"
      @valid_tokens << sha1.hexdigest
    end

    if @valid_tokens.index(params[:token]) == nil
      @user = User.new
      @user.errors.add :token, I18n.t('commons.token_invalid')
      return
    end

    @user = User.invite! user_params, nil do |u|
      u.skip_confirmation!
      u.sent_email = true
      u.invitation_sent_at = Time.now.utc
      u.invitation_parent_company_id = params[:invitation_parent_company_id]
      if params[:lang] == "en" or params[:lang] == "de"
        u.locale = params[:lang]
      else
        u.locale = I18n.default_locale
      end

    end
    @user.update_attribute(:short_token, @user.raw_invitation_token) if @user.persisted?

    # Send new registration email to netcos administrator
    BaseMailer.with(user: @user).registration_email.deliver

  end

  private

  def user_params
    permit = [:first_name, :last_name, :email, :company]
    permit << :role_type
    params.require(:user).permit(*permit)
  end
end
