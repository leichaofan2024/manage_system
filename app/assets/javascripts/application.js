// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//

//= require rails-ujs
//= require jquery
//= requie jquery_ujs
//= require moment
//= require bootstrap-datetimepicker
//= require bootstrap/dropdown
//= require jquery-ui/widgets/sortable
//= require bootstrap-sprockets
//= require select2
//= require_tree .

jQuery(window).load(function() {

   "use strict";

   // Page Preloader
   jQuery('#preloader').delay(350).fadeOut(function(){
      jQuery('body').delay(350).css({'overflow':'visible'});
   });
});

/*行点击事件*/
$(document).ready(function($) {
    $(".row-click-able").click(function() {
        window.document.location = $(this).data("url");
    });
});
/*结束*/
jQuery(document).ready(function() {
  "use strict";
// Minimize Button in Panels
   jQuery('.minimize').click(function(){
      var t = jQuery(this);
      var p = t.closest('.panel');
      if(!jQuery(this).hasClass('maximize')) {
         p.find('.panel-body, .panel-footer').slideUp(200);
         t.addClass('maximize');
         t.html('&plus;');
      } else {
         p.find('.panel-body, .panel-footer').slideDown(200);
         t.removeClass('maximize');
         t.html('&minus;');
      }
      return false;
   });
   // Add class everytime a mouse pointer hover over it
   jQuery('.nav-bracket > li').hover(function(){
      jQuery(this).addClass('nav-hover');
   }, function(){
      jQuery(this).removeClass('nav-hover');
   });

   // Tooltip
   jQuery('.tooltips').tooltip({ container: 'body'});
   jQuery('.menutoggle').click(function(){

      var body = jQuery('body');
      var bodypos = body.css('position');

      if(bodypos != 'relative') {

         if(!body.hasClass('leftpanel-collapsed')) {
            body.addClass('leftpanel-collapsed');
            jQuery('.nav-bracket ul').attr('style','');

            jQuery(this).addClass('menu-collapsed');

         } else {
            body.removeClass('leftpanel-collapsed chat-view');
            jQuery('.nav-bracket li.active ul').css({display: 'block'});

            jQuery(this).removeClass('menu-collapsed');

         }
      }
   });
   jQuery('.leftpanel .nav-parent > a').on('click', function() {

       var parent = jQuery(this).parent();
       var sub = parent.find('> ul');

       // Dropdown works only when leftpanel is not collapsed
       if(!jQuery('body').hasClass('leftpanel-collapsed')) {
          if(sub.is(':visible')) {
             sub.slideUp(200, function(){
                parent.removeClass('nav-active');
                jQuery('.mainpanel').css({height: ''});
                adjustmainpanelheight();
             });
          } else {
             closeVisibleSubMenu();
             parent.addClass('nav-active');
             sub.slideDown(200, function(){
                adjustmainpanelheight();
             });
          }
       }
       return false;
    });
    function closeVisibleSubMenu() {
      jQuery('.leftpanel .nav-parent').each(function() {
         var t = jQuery(this);
         if(t.hasClass('nav-active')) {
            t.find('> ul').slideUp(200, function(){
               t.removeClass('nav-active');
            });
         }
      });
   }
   function adjustmainpanelheight() {
      // Adjust mainpanel height
      var docHeight = jQuery(document).height();
      if(docHeight > jQuery('.mainpanel').height())
         jQuery('.mainpanel').height(docHeight);
   }
   adjustmainpanelheight();

 });


 $(function () {
   $('[data-toggle="tooltip"]').tooltip()
 })
