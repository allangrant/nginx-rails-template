file 'app/stylesheets/colors.sass', <<-CODE
!background_color               ||= #fff

!font_color                     ||= #333
!quiet_color                    ||= !font_color + #333
!loud_color                     ||= !font_color - #222

!header_color                   ||= !font_color - #111

!link_color                     ||= #09c
!link_hover_color               ||= #000
!link_focus_color               ||= !link_hover_color
!link_active_color              ||= !link_color + #333
!link_visited_color             ||= !link_color - #333

!feedback_border_color          ||= #DDD
!success_color                  ||= #264409
!success_bg_color               ||= #E6EFC2
!success_border_color           ||= #C6D880

!notice_color                   ||= #514721
!notice_bg_color                ||= #FFF6BF
!notice_border_color            ||= #FFD324

!error_color                    ||= #8A1F11
!error_bg_color                 ||= #FBE3E4
!error_border_color             ||= #FBC2C4

!highlight_color                ||= #FF0
!added_color                    ||= !loud_color
!added_bg_color                 ||= #7bff7f
!removed_color                  ||= !loud_color
!removed_bg_color               ||= #fb7f7f

!blueprint_table_header_color   ||= !background_color - #111
!blueprint_table_stripe_color   ||= !background_color - #080808
CODE


file 'app/stylesheets/scaffold.sass', <<-CODE
!container_width = 950px
!fieldset_border_width = 1px
!fieldset_border = !fieldset_border_width "solid" #ccc
!fieldset_padding = 40px
!field_space = 10px
!field_border_width = 1px
!field_border = !field_border_width "solid" #bbb
!field_padding = 6px
!field_border_focus = !field_border_width "solid" #666
!fieldset_inner_width = !container_width - !fieldset_padding * 2

=field-columns(!columns)
  :float left
  !field_width = (!container_width - !fieldset_padding * 2 - !field_space * (!columns - 1)) / !columns
  :width= !field_width
  :padding-right= !field_space
  label, input, textarea
    :width= !field_width - !field_padding * 2
  .date_select
    :width= ((!field_width - 6) / 3) * (1/0.32)
  .datetime_select
    :width= ((!field_width - 35) / 5) * (1/0.18)

=scaffold
  +heavy-headers

  fieldset
    :background= !background_color - #131515
    :border-color= !background_color - #353A3A
    :padding-left= !fieldset_padding - !fieldset_border_width
    :padding-right= !fieldset_padding - !fieldset_border_width - !field_space 
    :border= !fieldset_border
      
    .field-1
      +field-columns(1)

    .field-2
      +field-columns(2)

    .field-3
      +field-columns(3)

    label
      +font-size(1.2)

    select
      :width 100%

    .date_select
      select
        :width 32%

    .datetime_select
      select
        :width 18%

    textarea
      :border= !field_border
      :padding= (!field_padding - !field_border_width + 1) (!field_padding - !field_border_width)
      &:focus
        :border= !field_border_focus

    select
      :border= !field_border
      :padding= !field_padding - !field_border_width
      &:focus
        :border= !field_border_focus

    .text_field
      input
        :margin 5px 0
        :border= !field_border
        :padding= !field_padding - !field_border_width
        &:focus
          :border= !field_border_focus

    .submit
      :float right
      :margin-right= !field_space
      :clear both

  .error
    :background= !error_bg_color url("/images/icons/stop.png") "no-repeat" "scroll" "9px" "center"
    :padding-left 50px
  .success
    :background= !success_bg_color url("/images/icons/smiley.png") "no-repeat" "scroll" "9px" "center"
    :padding-left 50px
  .notice
    :background= !notice_bg_color url("/images/icons/notice.png") "no-repeat" "scroll" "9px" "center"
    :padding-left 50px
  a.add
    :background= url("/images/icons/add.png") "no-repeat" "scroll" "left" "center"
    :padding 9px 10px 9px 40px

  table.list
    th, td
      :padding 9px 10px 9px 5px

  .show
    .field
      +span(4)
      +append(1)
      :float left
      +font-size(1.5)
      :clear both
      :text-align right
    .value
      :width= !container_width - 190
      +font-size(1.2)
      :float left

  .links
    :text-align right
    :clear both
    +font-size(1.2)
    :padding 0.75em 0em
    a
      :font-weight bold
      :padding-left 2em
CODE

gsub_file 'app/stylesheets/screen.sass', /^@import main$/, <<-CODE
@import scaffold
@import main
CODE

gsub_file 'app/stylesheets/screen.sass', /^\+main$/, <<-CODE
+scaffold
+main
CODE

gsub_file 'app/controllers/application_controller.rb', /^end$/, <<-CODE
  before_filter :set_meta

  private
  ROOT_TITLE = '#{APPLICATION.titlecase}'

  def title(page_title)
    @page_title = "#\{page_title} | \#{ROOT_TITLE}"
  end

  def set_meta
    @page_title = ROOT_TITLE
    @page_description = '#{APPLICATION.titlecase} - a new rails application'
    @page_keywords = 'rails, app'
  end
end
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
    -# javascript_include_tag('jquery')
    = google_analytics
  %body
    #container
      = render :partial => "shared/header"
      #center
        = yield(:flash) || show_flash(flash)
        = yield
      = render :partial => "shared/footer"
CODE


file 'app/views/shared/_header.haml', <<-CODE
= link_to 'Home', '/'
CODE


file 'app/views/shared/_footer.haml', <<-CODE
CODE


run "cp -r #{TEMPLATE_PATH}/images/* public/images"
run "mv public/images/icons/favicon.ico public"