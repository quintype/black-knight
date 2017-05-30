namespace :dispose_env do
  desc "TODO"
  task dispose_env: :environment do
      DisposableEnvs = DeployEnvironment.where(disposable: true)
      DisposableEnvs.each do |dispose_env|
          ScaleContainerJob.perform_now(dispose_env.id,1,0)
      end
  end
end
