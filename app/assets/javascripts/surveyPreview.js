var PT = PT || {};

PT.nextInput = function(event){
  // Refactor
  var index = PT.survey.inputs.indexOf(PT.selectedInput());
  var direction = $(event.currentTarget).attr("data-direction");
  PT.selectedInput().selected(false);

  if(direction === "right"){
    if(index < PT.survey.inputs().length - 1){
      PT.selectedInput(PT.survey.inputs()[index + 1]);
      PT.selectedInput().selected(true);
    } else {
      PT.selectedInput(PT.survey.inputs()[0]);
      PT.selectedInput().selected(true);
    }
  } else {
    if(index > 0){
      PT.selectedInput(PT.survey.inputs()[index - 1]);
      PT.selectedInput().selected(true);
    } else {
      PT.selectedInput(_.last(PT.survey.inputs()));
      PT.selectedInput().selected(true);
    }
  }
};

PT.openPreview = function(){
  // Hack?
  window.open(window.location.origin + Routes.preview_survey_path(PT.survey.id));
};

PT.closePreview = function(){
  window.close();
};