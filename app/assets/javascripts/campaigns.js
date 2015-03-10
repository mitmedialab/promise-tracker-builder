var PT = PT || {};

// Create new campaign

$(function(){
  $("#new_campaign").on("submit", function(){
    if(!PT.validateOverview(this)){
      return false;
    }
  });

  jQuery.extend(jQuery.validator.messages, I18n.t("defaults.validations"));
});

// Edit campaign

PT.nextFormPage = function(){
  var page = $(this).parents(".form-page");
  var valid = PT.validateOverview(".edit_campaign");
  if(valid) {
    page.next().fadeIn();
    page.css({'display':'none'});
  }
};

PT.previousFormPage = function(){
  var page = $(this).parents(".form-page");

  $(this).parents(".form-page").prev().fadeIn();
  $(this).parents(".form-page").css({'display':'none'});
};

PT.updateDisplay = function($input, $display){
  $display.html($input.val());
};

PT.validateOverview = function(formSelector){
  var validator = $(formSelector).validate({
    rules: {
      "campaign[title]": {required: true, minlength: 5},
      "campaign[description]": {required: true},
      "campaign[goal]": {required: true},
      "campaign[data_collectors]": {required: true},
      "campaign[submissions_target]": {required: true, number: true},
      "campaign[audience]": {required: true}
    }
  });

  return validator.form();
};

PT.validateProfile = function(formSelector){
  var validator = $(formSelector).validate({
    rules: {
      "campaign[title]": {required: true},
      "campaign[description]": {required: true},
      "campaign[organizers]": {
        required: function(){
          return !$("#campaign_anonymous").is(":checked");
        }
      }
    }
  });

  return validator.form();
};

PT.scrollToError = function(){
  $('html body').animate({
    scrollTop: $(".error").first().offset().top - 80
  }, 500);
}

PT.toggleTip = function(event){
  $(event.currentTarget).find(".body").slideToggle();
};
