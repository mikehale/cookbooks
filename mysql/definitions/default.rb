define :mysql_create_database do
  create_statement = %(create database IF NOT EXISTS #{params[:database]} CHARACTER SET #{node[:mysql][:character_set]} COLLATE #{node[:mysql][:collation]};
                      GRANT ALL PRIVILEGES ON #{params[:database]}.*
                      TO '#{params[:user]}'@'localhost' IDENTIFIED BY '#{params[:password]}')

  execute("create database: #{params[:database]}") do
    mysql = "mysql --user=root --password='#{node[:mysql][:root_password]}'"
    command %(#{mysql} -e "#{create_statement}")
    only_if do
      `#{mysql} -e "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = '#{params[:database]}'" | wc -l`.chomp == "0"
    end
  end
end
