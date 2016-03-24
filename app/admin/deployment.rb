ActiveAdmin.register Deployment do
  actions :all, except: [:create, :update, :edit]
end
