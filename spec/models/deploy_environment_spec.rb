require "rails_helper"

describe DeployEnvironment do
  let(:deploy_environment) { create(:deploy_environment) }
  let(:user) { create(:user) }

  it "can serialize it's configurations" do
    create(:config_file, deploy_environment: deploy_environment,
                       path: "/app/config.yml",
                       value: "foobar")
    expect(deploy_environment.config_files_as_json).to eq({"/app/config.yml" => "foobar"})
  end

  it "can schedule a new deployment" do
    deploy_environment = create(:deploy_environment)
    create(:config_file, deploy_environment: deploy_environment,
                       path: "/app/config.yml",
                       value: "foobar")
    deployment = deploy_environment.new_deployment("latest", user)
    expect(deployment).to be_valid
    expect(deployment.scheduled_by).to eq(user)
    expect(deployment.status).to eq("pending")
    expect(deployment.version).to eq("latest")
    expect(deployment.configuration).to eq('{"/app/config.yml":"foobar"}')
    expect(deployment.new_deploy_tag).to start_with("thepublisher-beta")
  end

  it "can reschedule a deployment" do
    create(:config_file, deploy_environment: deploy_environment,
                       path: "/app/config.yml",
                       value: "foobar")
    deployment = deploy_environment.new_deployment("latest", user)
    deployment.save

    redeploy = deployment.redeployment(user)
    expect(redeploy).to be_valid
    expect(redeploy.scheduled_by).to eq(user)
    expect(redeploy.status).to eq("pending")
    expect(redeploy.configuration).to eq('{"/app/config.yml":"foobar"}')
    expect(redeploy.redeploy_of).to eq(deployment)
    expect(redeploy.new_deploy_tag).to eq(deployment.deploy_tag)
  end

  it "only builds original deployments" do
    deployment = deploy_environment.new_deployment("latest", user)
    expect(deployment).to be_buildable

    deployment.save

    redeploy = deployment.redeployment(user)
    expect(redeploy).not_to be_buildable
  end

  describe "destroy" do
    before do
      create(:config_file, deploy_environment: deploy_environment,
                         path: "/app/config.yml",
                         value: "foobar")
      deployment = deploy_environment.new_deployment("latest", user)
      deployment.save
    end

    it "deletes dependent associations on delete of itself" do
      expect(deploy_environment.config_files.count).to eq(1)
      expect(deploy_environment.deployments.count).to eq(1)

      deploy_environment.destroy

      expect(DeployEnvironment.where(id: deploy_environment.id).first).to be_nil
      expect(deploy_environment.config_files.count).to eq(0)
      expect(deploy_environment.deployments.count).to eq(0)
    end
  end
end
