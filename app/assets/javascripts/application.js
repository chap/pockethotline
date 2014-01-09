//= require jquery
//= require jquery_ujs
//= require jquery.autoResize.js
//= require jquery.timeago.js
//= require jquery.validate.min.js
//= require bootstrap2

function add_fields(link, association, content) {
  var new_id = new Date().getTime();

  // replace 'random' with timestamp
  var regexp = new RegExp("random", "g");
  content = content.replace(regexp, new_id);
  
  var regexp2 = new RegExp("new_" + association, "g");
  content = content.replace(regexp2, new_id);

  var show_button = new RegExp("display:none;", "g");
  content = content.replace(show_button, '');

  $(link).before(content);
};

function toggle_status(url) {
  $.post(url, function(data) {
  }); 
}

function remove_fields(link) {
  $(link).closest(".fields").find("input[type=hidden]").val("1");
  $(link).closest(".fields").hide();
}

// validate character limit
$(document).ready(function() {

  displayCharactersRemaining();

  $('[data-character-limit]').keyup(function() {
    displayCharactersRemaining();
  });

  function displayCharactersRemaining() {
    $('[data-character-limit]').each(function() {
      limit = parseInt($(this).attr('data-character-limit'));
      remaining = limit- $(this).val().length;
      display = $(this).siblings('.display-limit');

      message = remaining + " characters remaining";
      display.html(message);

      if (remaining <= 0) {
        display.addClass('over');
      } else {
        display.removeClass('over');
      }
    });
  }
});