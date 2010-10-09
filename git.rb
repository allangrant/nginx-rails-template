# Ignore auto-generated files
run "touch tmp/.gitignore log/.gitignore vendor/.gitignore"
run %{find . -type d -empty | grep -v "vendor" | grep -v ".git" | grep -v "tmp" | xargs -I xxx touch xxx/.gitignore}

file '.gitignore', <<-CODE
log/*.log
log/*.pid
tmp/**/*
.DS_Store
mkmf.log
config/database.yml
config/mailer.yml
config/mongrel_cluster.yml
public/stylesheets/compiled/*
public/system/*
public/.htaccess
app/stylesheets/.sass-cache
db/schema.rb
*~
CODE

# Prepare for distributed development
run "cp config/database.yml config/database.yml.example"

# Initialize submodules
git :submodule => "init"

# Connect remote origin
git :remote => "add origin #{GIT_ORIGIN}",
    :config => "--add branch.master.remote origin",
    :config => "--add branch.master.merge refs/heads/master"

# Commit all work so far to the repository
git :add => '.'
git :commit => "-m 'Initial commit'"