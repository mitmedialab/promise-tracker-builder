PT = PT || {};

PT.downloadCsv = function(serverResponse){
  var survey = serverResponse.survey;
  var responses = serverResponse.responses;
  var a = document.createElement('a');
  var csvString = "";

  //Write title & prompts
  csvString += survey.title + "\n";
  csvString += 'Date of submission,"Location of submission (lat, lon)",';
  survey.inputs.forEach(function(input){
    csvString += '"' + input.label + '",';
  })

  //Write responses
  responses.forEach(function(response){
    csvString += "\n" + new Date(response.timestamp) + "," 
      + '"' + response.locationstamp.lat + ", " + response.locationstamp.lon + '",';

    response.answers.forEach(function(answer){
      if(answer.value){
        if (typeof(answer.value) == "string"){
          csvString += '"' + answer.value + '"';
        } else if(answer.value.constructor == Array) {
          csvString += '"' + answer.value.join(",") + '"';
        } else {
          csvString += '"' + answer.value.lat + ", " + answer.value.lon + '"';
        }
      }
      csvString += ",";
    })
  })

  a.href = "data:application/csv;charset=utf-8," + "\uFEFF" + encodeURIComponent(csvString);
  a.target = "_blank";
  a.download = "PT_Data_" + survey.code + ".csv";
  document.body.appendChild(a);
  a.click();
};