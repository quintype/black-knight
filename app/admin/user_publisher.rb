ActiveAdmin.register UserPublisher do
  permit_params :user_id, :publisher_id
  
  form do |f|
    f.inputs "User Publisher Link" do
      f.input :user, collection: User.all.sort_by { |user | p user.email }
      f.input :publisher
    end
  f.actions
  end

end
