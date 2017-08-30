FactoryGirl.define do
  factory :publisher do
    name "The Publisher"
    username "thepublisher"
    admin_email "dev-core@quintype.com"
    quintype_id_of_publisher 1
  end

  factory :deploy_environment do
    publisher
    name "beta"
  end

  factory :config_file do
    deploy_environment
  end

  factory :user do
    name "Quintype User"
    email "foobar1234@quintype.com"
    password "foobar1234"
  end

  factory :user_publisher do
    user
    publisher
  end
end
