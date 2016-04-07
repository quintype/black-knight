require "rails_helper"

describe DeployEnvironment do
  it "can serialize it's configurations" do
    deploy_environment = FactoryGirl.create(:deploy_environment)
    FactoryGirl.create(:config_file, deploy_environment: deploy_environment,
                       path: "/app/config.yml",
                       value: "foobar")
    expect(deploy_environment.config_files_as_json).to eq({"/app/config.yml" => "foobar"})
  end

  it "can schedule a new deployment" do
    deploy_environment = FactoryGirl.create(:deploy_environment)
    FactoryGirl.create(:config_file, deploy_environment: deploy_environment,
                       path: "/app/config.yml",
                       value: "foobar")
    user = FactoryGirl.create(:user)
    deployment = deploy_environment.new_deployment("latest", user)
    expect(deployment).to be_valid
    expect(deployment.scheduled_by).to eq(user)
    expect(deployment.status).to eq("pending")
    expect(deployment.version).to eq("latest")
    expect(deployment.configuration).to eq('{"/app/config.yml":"foobar"}')
  end
end
