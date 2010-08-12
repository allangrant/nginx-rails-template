run "rm README"
run "rm public/index.html"
run "rm public/favicon.ico"
run "rm public/robots.txt"
run "rm public/images/rails.png"
gsub_file 'config/environment.rb', /^\s*#.*$/, ""
gsub_file('config/environment.rb', /^(\s*\n)+$/, "")
