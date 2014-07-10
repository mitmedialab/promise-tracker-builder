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

PT.openPreview = function(){
  // Hack?
  window.open(window.location.origin + Routes.preview_survey_path(PT.survey.id));
};

PT.closeWindow = function(){
  window.close();
};