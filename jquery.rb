run 'curl -L http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js > public/javascripts/jquery.js'
run 'curl -L http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.4/jquery-ui.min.js > public/javascripts/jquery-ui.js'

gsub_file 'app/views/layouts/application.haml', "-# javascript_include_tag('jquery')", "= javascript_include_tag('jquery', 'jquery-ui')"

# Example downloading a plugin:
# run 'curl -L http://plugins.jquery.com/files/jquery-corners-0.3_0.zip > jquery-corners-0.3_0.zip'
# run 'unzip -j jquery-corners-0.3_0.zip jquery-corners-0.3/jquery.corners.min.js'
# run 'mv jquery.corners.min.js public/javascripts/jquery.corners.js'
# run 'rm jquery-corners-0.3_0.zip'