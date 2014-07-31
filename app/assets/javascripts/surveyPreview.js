var PT = PT || {};

PT.nextInput = function(event){
  var index = PT.survey.inputs.indexOf(PT.selectedInput());
  var direction = $(event.currentTarget).attr("data-direction");

  if(direction === "right" && index < PT.survey.inputs().length - 1){
    PT.selectedInput(PT.survey.inputs()[index + 1]);
  } else if(direction === "left" && index > 0){
    PT.selectedInput(PT.survey.inputs()[index - 1]);
  }
};

PT.togglePreview = function(event){
  $(".preview-container").slideToggle();
  if($(this).html() === PT.flash.hide_preview){
    $(this).html(PT.flash.show_preview);
  } else {
    $(this).html(PT.flash.hide_preview);
  }
};