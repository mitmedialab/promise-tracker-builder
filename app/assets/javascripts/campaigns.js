// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

var PT = PT || {};

PT.nextFormPage = function(){
  var page = $(this).parents(".form-page");
  var valid = PT.validateCampaign();
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

PT.validateCampaign = function(){
  var validator = $(".edit_campaign").validate({
    rules: {
      "campaign[goal]": {required: true},
      "campaign[data_collectors]": {required: true},
      "campaign[submissions_target]": {required: true, number: true},
      "campaign[audience]": {required: true}
    }
  });

  return validator.form();
};

PT.openTip = function(event){
  $(event.currentTarget).find(".body").slideToggle();
};