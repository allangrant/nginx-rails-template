file 'config/database.yml', <<-CODE
base: &base
  adapter: mysql
  encoding: utf8
  reconnect: false
  pool: 5
  username: root
  password:
  socket: /tmp/mysql.sock
  
development:
  database: #{APPLICATION}_development
  <<: *base

test:
  database: #{APPLICATION}_test
  <<: *base

production:
  database: #{APPLICATION}_production
  <<: *base
CODE