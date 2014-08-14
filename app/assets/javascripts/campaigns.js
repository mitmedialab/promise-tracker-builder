var PT = PT || {};

// Edit campaign 

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

// Launch
PT.nextLaunchPage = function(){
  var page = $(this).parents(".form-page");
    page.next().fadeIn();
    page.css({'display':'none'});
};