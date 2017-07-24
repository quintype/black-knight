# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
User.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password',super_user: true)
AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password')
1.upto(50) do |i|
   @test_publisher  = Publisher.create!(quintype_id_of_publisher: i, name: "test#{i}", admin_email: "test@test.com",username: "test#{i}")
   @test_cluster = Cluster.create!(name: "test#{i}" ,kube_api_server: "test#{i}" )
   DeployEnvironment.create!(publisher_id: @test_publisher.id , name: "test#{i}" , cluster_id: @test_cluster.id, app_name: "test#{i}" ,repository: "test")
   User.create!(email: "admin#{i}@example.com", password: 'password', password_confirmation: 'password',super_user: true,name: "admin#{i}")
end

