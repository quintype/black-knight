class DeploymentBaseJob < ApplicationJob
  def post_slack(deployment, base_url, channel="#deploy-#{Rails.application.secrets[:qt_environment]}")
    user = deployment.scheduled_by
    environment = deployment.deploy_environment
    messages = {"building" => "Deploying `#{environment.app_name}/#{environment.name}` with tag `#{deployment.version}`",
                "success" => "Deployed `#{environment.app_name}/#{environment.name}` with tag `#{deployment.deploy_tag}`.",
                "failed-build" => "Build failed `#{environment.app_name}/#{environment.name}` <#{base_url}/deploy/#{deployment.id}|More Details>",
                "failed-deploy" => "Deploy failed `#{environment.app_name}/#{environment.name}` <#{base_url}/deploy/#{deployment.id}|More Details>"}

    PostToSlack.post(messages[deployment.status], user: user.name || user.email)
  end
end