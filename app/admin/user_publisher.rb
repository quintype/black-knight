ActiveAdmin.register UserPublisher do
  permit_params :user_id, :publisher_id
  
  form do |f|
    f.inputs "User Publisher Link" do
      f.input :user, collection: User.all.sort_by { |user | p user.email }
      f.input :publisher, collection: Publisher.all.sort_by { |publisher| p publisher.name }
  
    end
  f.actions
  end

  filter :user, collection: proc { User.order(:name) }
  filter :publisher, collection: proc { Publisher.order(:name) }

end
