ActiveAdmin.register User do
  permit_params :email, :name, :password, :password_confirmation, :super_user, :otp_required_for_login

  index do
    selectable_column
    id_column
    column :email
    column :name
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    column :otp_required_for_login, label: 'MFA Enabled'
    actions
  end

  filter :email
  filter :name
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at
  filter :otp_required_for_login , label: 'MFA Enabled'

  form do |f|
    f.inputs "User Details" do
      f.input :email
      f.input :name
      f.input :password
      f.input :password_confirmation
      f.input :super_user, as: :boolean
      f.input :otp_required_for_login, label: 'Enable MFA', as: :boolean
    end
    f.actions
  end

end
