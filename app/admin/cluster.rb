ActiveAdmin.register Cluster do
  permit_params :name, :kube_api_server

  index do
    selectable_column
    id_column
    column :name
    column :kube_api_server
    column :created_at
    actions
  end

  filter :name
  filter :kube_api_server
  filter :created_at

  form do |f|
    f.inputs "Cluster Details" do
      f.input :name
      f.input :kube_api_server
    end
    f.actions
  end

end
