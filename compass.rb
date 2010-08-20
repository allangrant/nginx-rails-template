gem 'haml', :version => '3.0.16', :source => 'http://gemcutter.org'
gem 'compass', :version => '0.10.4', :source => 'http://gemcutter.org'
run 'compass init rails . --sass-dir "app/stylesheets" --css-dir "public/stylesheets/compiled"'

run "rm app/stylesheets/ie.scss"
file 'app/stylesheets/ie.sass', <<-CODE
@import blueprint/ie

+blueprint-ie

#container
  :text-align left
CODE


run "rm app/stylesheets/print.scss"
file 'app/stylesheets/print.sass', <<-CODE
@import blueprint/print

+blueprint-print
CODE

run "rm app/stylesheets/screen.scss"
file 'app/stylesheets/screen.sass', <<-CODE
@import colors
@import blueprint
@import compass/reset
@import utilities
@import main

+blueprint-typography
+blueprint-interaction

+utilities
+main
CODE


file 'app/stylesheets/utilities.sass', <<-CODE
@import blueprint-fixed

=grid
  :background url("/images/bg/grid.png")
=hgrid
  :background url("/images/bg/hgrid.png")
=vgrid
  :background url("/images/bg/vgrid.png")
  
=heavy-headers
  h1, h2, h3, h4
    :font-weight bold
  h2
    :margin-top 0.75em
  h3
    :margin-top 1em

=utilities
  +blueprint-fixed
  
=font-size(!font_size, !rows = 1)
  @if !font_size == 3
    :font-size 3em
    :line-height 1
    :margin-bottom 0.5em
  @if !font_size == 2
    :font-size 2em
    :margin-top 0.24em
    :margin-bottom 0.51em
  @if !font_size == 1.5
    :font-size 1.5em
    :line-height 1
    @if !rows == 1
      :margin-bottom 1em
    @if !rows == 2
      :margin-top .9em
      :margin-bottom .1em
  @if !font_size == 1.2
    :font-size 1.2em
    :line-height 1.25
    @if !rows == 1
      :margin-top 0.15em
      :margin-bottom 1.1em
    @if !rows == 2
      :margin-top 1.25em
      :margin-bottom 0em
  @if !font_size == 1
    :font-size 1em
    @if !rows == 1
      :margin-top .2em
      :margin-bottom -.2em
    @if !rows == 2
      :margin-top 1.5em
      :margin-bottom 0
CODE


file 'app/stylesheets/blueprint-fixed.sass', <<-CODE
//blueprint fixed for line-height 1.5em (18px) perfection
=blueprint-fixed
  +blueprint-form-fixed
  +blueprint-typography-fixed
  #container
    +container
    
=blueprint-form-fixed
  label
    :font-weight bold
  fieldset
    :padding 1.42em 1.5em 1.34em
    :margin 0 0 1.5em 0
    :border 1px solid #ccc
    &.withlegend
      :padding 1.5em 1.5em 1.34em
  legend
    :font-weight bold
    :font-size 1.2em
    :line-height 1.25em
  input
    &.button
      :margin 8px 0
      :padding 4px
    &.file
      :margin 5px 0
      :height 26px
    &.radio, &.checkbox
      :margin -2px 0
    &.text, &.password
      :margin 5px 0
      :border 1px solid #bbb
      :width 300px
      :padding 5px
      :height 14px
      &:focus
        :border 1px solid #666
    &.title
      :font-size 1.5em
  input.title
    :margin 5px 0 11px
    :border 1px solid #bbb
    :width 300px
    :padding 7px 5px
    :height 22px
    &:focus
      :border 1px solid #666
  textarea
    :margin 5px 0
    :border 1px solid #bbb
    :width 300px
    :height 102px
    :padding 6px 5px
    :line-height 18px
    &:focus
      :border 1px solid #666
  select
    :margin 5px 0
    :border 1px solid #bbb
    :height 26px
    :padding 5px
    &:focus
      :border 1px solid #666


=blueprint-typography-fixed      
  table
    :margin-bottom 1.5em
  th
    :padding 0px 10px 0px 5px
  td
    :padding 0px 10px 0px 5px
    :vertical-align top
  pre
    :margin-top 0
    :white-space normal
  blockquote
    :margin-top 0
  hr
    :background #aaa
    :color #aaa
    :clear both
    :float none
    :width 100%
    :height 1px
    :margin 0 0 1.42em
    :border none
  small
    :font-size 0.8em
    :margin-bottom 1.875em
    :line-height 1.875em    

=clearfix-alt
  :display block
  &:after
    :content "\\0020"
    :display block
    :height 0
    :clear both
    :visibility hidden
    :overflow hidden
CODE


file 'app/stylesheets/colors.sass', <<-CODE
!font_color            ||= #333
!quiet_color           ||= !font_color + #333
!loud_color            ||= !font_color - #222

!header_color          ||= !font_color - #111

!link_color            ||= #009
!link_hover_color      ||= #000
!link_focus_color      ||= !link_hover_color
!link_active_color     ||= !link_color + #C00
!link_visited_color    ||= !link_color - #333

!feedback_border_color ||= #DDD
!success_color         ||= #264409
!success_bg_color      ||= #E6EFC2
!success_border_color  ||= #C6D880

!notice_color          ||= #514721
!notice_bg_color       ||= #FFF6BF
!notice_border_color   ||= #FFD324

!error_color           ||= #8A1F11
!error_bg_color        ||= #FBE3E4
!error_border_color    ||= #FBC2C4

!highlight_color       ||= #FF0
!added_color           ||= #FFF
!added_bg_color        ||= #060
!removed_color         ||= #FFF
!removed_bg_color      ||= #900
CODE


file 'app/stylesheets/main.sass', <<-CODE
=main
  // Add application styles here
CODE


file 'app/views/layouts/application.haml', <<-CODE
!!!
%html{html_attrs}
  %head
    %meta{'http-equiv' => 'Content-Type', :content => 'text/html;charset=UTF-8'}
    %meta{:name => 'Keywords', :content => h(@page_keywords)}
    %meta{:name => 'Description', :content => h(@page_description)}
    %link{:rel => "shortcut icon", :href => image_path('/favicon.ico') }
    %title
      = h(@page_title)
    = stylesheet_link_tag('compiled/screen', :media => 'screen, projection')
    = stylesheet_link_tag('compiled/print', :media => 'print')
    /[if IE]
      = stylesheet_link_tag('compiled/ie', :media => 'screen, projection')

  %body
    #container
      = yield(:flash) || show_flash(flash)
      = yield
    = google_analytics
CODE

file 'app/helpers/application_helper.rb', <<-CODE
# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def show_flash(flash)
    output = ""
    flash.each do |key,value|
      output += content_tag :div, value, :class => key
    end
    content_for :flash, ''
    return output
  end
  
  def google_analytics
    return "" if !defined?(GOOGLE_ANALYTICS_ID) || GOOGLE_ANALYTICS_ID.blank?
    return <<-END
<script type="text/javascript">
  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', '\#{GOOGLE_ANALYTICS_ID}']);
  _gaq.push(['_trackPageview']);
  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();
</script>
END
  end
  
end
CODE

gsub_file 'config/environments/production.rb', "# config.threadsafe!", <<-CODE
# config.threadsafe!

GOOGLE_ANALYTICS_ID = "" # when this is set, google_analytics helper will insert google analytics code when running in production env
CODE