class Api::DeployEnvironmentsController < ApplicationController
  before_action :authenticate_user!, :unconfirmed_mfa!
  respond_to :json
  skip_before_filter :verify_authenticity_token, only: [:scale,:create]

  # FIXME: Terrible modelling, this should be as_json(include:). Or use jbuilder.
  def attributes_for_environment_page(deploy_environment, page=nil)
    if page
      deploy_environment.deployments.all.reverse_order.page(page).per(5).map {|deployment|
        deployment.attributes.slice("id", "version", "deploy_tag", "status")
      }
    else
      deploy_environment.attributes.merge(
        deployments: deploy_environment.deployments.latest.map { |deployment|
          deployment.attributes.slice("id", "version", "deploy_tag", "status")
        },
        migrations: deploy_environment.migrations.latest.map { |migration|
          migration.attributes.slice("id", "version", "deploy_tag", "status", "migration_command")
        }
      )
    end
  end

  def show
    respond_with deploy_environment: attributes_for_environment_page(current_user.deploy_environments.find(params[:id]))
  end

  def create
    publisher_id = params[:publisher_id]
    deploy_env_name = params[:name]
    repository = params[:repository]
    app_name = params[:app_name]
    cluster_id = params[:cluster_id]
    disposable = params[:disposable] || false
    migratable = params[:migratable] || false

    deploy_environment = DeployEnvironment.create!(publisher_id: publisher_id , name: deploy_env_name , cluster_id: cluster_id, app_name: app_name ,repository: repository, migratable: migratable, disposable: disposable)
    kube = CreateKube.new(deploy_environment)

    render json: { deploy_environment: deploy_environment ,kube_output: kube.create! }
  end

  def scale
    deploy_environment = current_user.deploy_environments.find(params[:deploy_environment_id])
    size = params[:size]
    if(deploy_environment.disposable? && size < 4)
      ScaleContainerJob.perform_later(deploy_environment.id, current_user.id, size)
      render status: 201, json: {"state": "accepted"}
    else
      render status: 422, json: {error: {message: "Cannot Scale This Container"}}
    end
  end

  def load_more_deployments
    respond_with more_deployments: attributes_for_environment_page(current_user.deploy_environments.find(params[:deploy_environment_id]), params[:page])
  end
end
