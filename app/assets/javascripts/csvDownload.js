PT = PT || {};

PT.downloadCsv = function(serverResponse){
  var survey = serverResponse.survey;
  var responses = serverResponse.responses;
  var a = document.createElement('a');
  var csvString = "";

  //Write title & prompts
  csvString += survey.title + "\n";
  csvString += '"Date of submission","Location of submission (lat, lon)",';
  survey.inputs.forEach(function(input){
    csvString += '"' + input.label + '",';
  })

  //Write responses
  responses.forEach(function(response){
    csvString += "\n" + '"' + new Date(response.timestamp) + '", '
      + '"' + response.locationstamp.lat + ", " + response.locationstamp.lon + '",';

    response.answers.forEach(function(answer){
      if(answer.value){
        if (typeof(answer.value) == "string" || typeof(answer.value) == "number"){
          csvString += '"' + answer.value + '"';
        } else if(answer.value.constructor == Array) {
          csvString += '"' + answer.value.join(",") + '"';
        } else if (typeof(answer.value) == "object") {
          csvString += '"' + answer.value.lat + ", " + answer.value.lon + '"';
        }
      } else {
        csvString += '""';
      }
      csvString += ",";
    })
  });

  var filename = "PT_Data_" + survey.code + ".csv";
  var blob = new Blob(["\uFEFF" + csvString], { encoding:"UTF-8", type: 'text/csv' });
  if (navigator.msSaveBlob) { // IE 10+
    navigator.msSaveBlob(blob, filename);
  } else {
    var link = document.createElement("a");
    if (link.download !== undefined) { // feature detection
      // Browsers that support HTML5 download attribute
      var url = URL.createObjectURL(blob);
      link.setAttribute("href", url);
      link.setAttribute("download", filename);
      link.style.visibility = 'hidden';
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
    }
  };
};