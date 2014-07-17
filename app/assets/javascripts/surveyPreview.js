var PT = PT || {};

PT.nextInput = function(event){
  var index = PT.survey.inputs.indexOf(PT.selectedInput());
  var direction = $(event.currentTarget).attr("data-direction");

  if(direction === "right" && index < PT.survey.inputs().length - 1){
    debugger
      PT.selectedInput(PT.survey.inputs()[index + 1]);
  } else if(direction === "left" && index > 0){
    debugger
      PT.selectedInput(PT.survey.inputs()[index - 1]);
  }
};