ActiveAdmin.register User do
  permit_params :email, :name, :password, :password_confirmation, :super_user, :unconfirmed_mfa

  index do
    selectable_column
    id_column
    column :email
    column :name
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    column :unconfirmed_mfa, label: 'MFA Enabled'
    actions
  end

  filter :email
  filter :name
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at
  filter :unconfirmed_mfa , label: 'MFA Enabled'

  form do |f|
    f.inputs "User Details" do
      f.input :email
      f.input :name
      f.input :password
      f.input :password_confirmation
      f.input :super_user, as: :boolean
      f.input :unconfirmed_mfa, label: 'Enable MFA', as: :boolean
    end
    f.actions
  end

  controller do
    def update_resource(object, attributes)
      update_method = attributes.first[:password].present? ? :update_attributes : :update_without_password
      object.send(update_method, *attributes)
    end
  end


end
