var PT = PT || {};

PT.openSurvey = function(){
  if(window.prompt("After launch, you will no longer be able to edit this survey. To confirm, please type 'launch'")){
    window.location.pathname = Routes.open_survey_path(PT.survey.id);
  }

};