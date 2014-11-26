var PT = PT || {};

PT.colors = [
  "#f5be59", 
  "#66c6ba", 
  "#ea7669", 
  "#545757", 
  "#42847b", 
  "#efa9a3",
  "#e6e7e8"
];

PT.renderCartoDBMap = function(containerId){
  var url, mapOptions;
  url = "http://cfcm.cartodb.com/api/v2/viz/21e86fd4-5887-11e4-b28c-0e018d66dc29/viz.json";
  mapOptions = {
    zoom: 15,
    center_lat: -19.9540425000,
    center_lon: -43.9385429000,
    scrollwheel: false,
    zoomControl: false,
    shareable: false,
    searchControl: false
  }; 

  $.getScript("http://libs.cartocdn.com/cartodb.js/v3/cartodb.js", function(){
    cartodb.createVis('map-viz', url, mapOptions)
    .done(function(){
      $(".cartodb-searchbox").hide();
    });
  });
};

PT.populateImages = function(responses, containerId){
  var $container = $(containerId);
  var images = [];
  var image;

  responses.forEach(function(response){
    response.answers.forEach(function(answer){

      if(answer.input_type == "image" && answer.value){
        images.push(answer.value);
      }
    })
  });

  $container.empty();
  images.forEach(function(url){
    image = '<img class="item"src="' + url + '">';
    $container.append(image);
  })
};

PT.renderGoogleMap = function(serverResponse){
  var markers = [];
  var surveyDefinition = {};
  var map = null,
      infoWindow = null;

  var attachMarkerClickEvent = function(marker, response){
    var image = null;
    var displayableAnswers = {};
    // 1. browse through answers, put all images to $image and displayable answers to $displayableAnswers.
    for(var i=0,len=response.answers.length;i<len;i++){
      var answer = response.answers[i];
      switch(answer.input_type){
        case 'location':
          break;
        case 'image':
          if(typeof answer.value!=='undefined' && answer.value){
            image = answer.value;
          }
          break;
        default:
          if(typeof answer.value!=='undefined' && answer.value){
            displayableAnswers[surveyDefinition[answer.id]] = answer.value;
          }
      }
    }
    // 2. construct infoWindow string
    var infoWindowImageHtml='';
    if(image !== null){
      infoWindowImageHtml = 
      '<div class="map-info-window-image">'+
        '<img src="'+image+'" alt="answer image"/>'+
      '</div>';
    } 
    var infoWindowTableHtml = '';
    if(Object.keys(displayableAnswers).length > 0){
      infoWindowTableHtml = '<div class="map-info-window-table"><table>';
      for(var i in displayableAnswers){
        infoWindowTableHtml += '<tr><td class="table-lable">'+i+'</td></tr><tr><td class="table-content">'+displayableAnswers[i]+'</td></tr>';
      }
      infoWindowTableHtml += '</table></div>';
    }
    var infoWindowContentHtml = 
      '<div class="map-info-window-content" id="' + response.id + '">'+
        infoWindowImageHtml+
        infoWindowTableHtml+
      '</div>';

    google.maps.event.addListener(marker, 'click', function(){
      infoWindow.setContent(infoWindowContentHtml);
      infoWindow.open(map, marker);
    });
  };  // func attachMarkerClickEvent

  window.mapInit = function(){
    // start initialization
    // create map
    var mapOptions = {
      zoom: 8,
      center: new google.maps.LatLng(-34.397, 150.644),
      scrollwheel: false
    };
    map = new google.maps.Map(document.getElementById('map-viz'), mapOptions);
    infoWindow = new google.maps.InfoWindow({
        content: '' 
    });

    // store survey definition
    var surveyInputs = serverResponse.survey.inputs;
    for(var i=0,len=surveyInputs.length;i<len;i++){
      var input = surveyInputs[i];
      surveyDefinition[input.id] = input.label;
    }

    // create map markers
    var surveyResponses = serverResponse.responses;
    for(var i=0,len=surveyResponses.length;i<len;i++){
      var response = surveyResponses[i];

      // 1 find geo location
      var lat = null,
          lon = null;
      for(var j=0,len2=response.answers.length;j<len2;j++){
        var answer = response.answers[j];
        if(typeof answer.input_type!=='undefined' && answer.input_type=='location' && typeof answer.value!=='undefined' && typeof answer.value.lon!=='undefined'){
          lat = answer.value.lat;
          lon = answer.value.lon;
          break;
        }
      }
      if(lat==null || lon==null){
        if(response.locationstamp && response.locationstamp.lat !== 'undefined' && response.locationstamp.long !== 'undefined'){
          lat = response.locationstamp.lat;
          lon = response.locationstamp.lon;
        } else {
          continue; // find if next response is a geolocation
        }
      }

      // 2. create that marker;
      if(lat && lon){
        var marker = new google.maps.Marker({
          map: map,
          position: new google.maps.LatLng(lat, lon)
        });
        markers.push(marker);

        // 3. attach onclick event
        attachMarkerClickEvent(marker, response);
      }
    } // for surveyResponses - created map markers

    // scale map viewport to include all the markers.
    var points = $.map(markers, function(a){
        return a.getPosition();
    });
    var bounds = new google.maps.LatLngBounds();
    for(var i=0;i<points.length;i++){
        bounds.extend(points[i]);
    }
    
    map.fitBounds(bounds);

  };  // func mapInit

  // load map script

  if(typeof google === 'undefined'){
    var script = document.createElement('script');
    script.type = 'text/javascript';
    script.src = 'https://maps.googleapis.com/maps/api/js?v=3.exp&' +
        'callback=mapInit';
    document.body.appendChild(script);
  } else {
    window.mapInit();
  }
};

PT.aggregateData = function(data){
  var survey = data.survey;
  var responses = data.responses;
  var answerAggregates = [];

  survey.inputs.forEach(function(input){
    var answers = [];
    var tally;
    var inputSummary = {
      id: input.id,
      label: input.label,
      type: input.input_type,
      answers: []
    };

    responses.forEach(function(response){
      answers.push(response.answers.filter(function(answer){
        return answer.id == input.id;
      })[0]);
    });

    switch(input.input_type){
      case 'select1':
        input.options.forEach(function(option){
          tally = answers.reduce(function(prev, current){
            return current.value == option ? prev + 1 : prev;
          }, 0);

          inputSummary.answers.push({label: option, tally: tally});
        })
        break;

      case 'select':
        input.options.forEach(function(option){
          tally = answers.reduce(function(acc, current){
            return current.value && current.value.indexOf(option) !== -1 ? acc + 1 : acc;
          }, 0);

          inputSummary.answers.push({label: option, tally: tally});
        })
        break;

      case 'number':
      case 'text':
        inputSummary.answers = answers.reduce(function(acc, current){
          if(current && current.value){
            acc.push(current.value);
          }
          return acc;
        },[]);
        break;
    }
    answerAggregates.push(inputSummary);
  })

  return answerAggregates;
};

PT.renderGraphs = function(aggregates, containerId){
  var $container = $(containerId);
  var $graphSquare;
  $container.empty();

  aggregates.forEach(function(input){
    if(input.type == "select" || input.type == "select1"){
      $graphSquare = $(document.createElement("div"));

      $graphSquare.addClass("col-md-12 graph-square");
      $graphSquare.attr("id", "graph-" + input.id)
      $container.append($graphSquare);

      switch(input.type){
        case "select1":
          PT.renderPieChart("#graph-" + input.id, input)
          break;

        case "select":
          PT.renderColumnChart("#graph-" + input.id, input)
          break;
      }
    }
  })

};

PT.renderPieChart = function(containerId, inputSummary){
  var data = inputSummary.answers.map(function(answer){
    return [answer.label, answer.tally];
  });

  $(containerId).highcharts({
    chart: {
      plotBackgroundColor: null,
      plotShadow: false,
    },
    colors: PT.colors,
    title: {
      text: inputSummary.label
    },
    tooltip: {
      pointFormat: '<b>{point.percentage:.1f}%</b><br>{point.count}'
    },
    credits: {
      enabled: false
    },
    plotOptions: {
      pie: {
        allowPointSelect: true,
        cursor: 'pointer',
        dataLabels: {
          enabled: true,
          format: '<b>{point.name}</b>: {point.percentage:.1f} %<br><span style="color: grey; font-size: .9em;">({point.y} ' + I18n.t("campaigns.monitor.responses") + ')</span>',
          style: {
              color: (Highcharts.theme && Highcharts.theme.contrastTextColor) || 'black'
          }
        }
      }
    },
    series: [{
      type: 'pie',
      name: '',
      data: data
    }]
  });
};

PT.renderColumnChart = function(containerId, inputSummary){
  var series = inputSummary.answers.map(function(answer){
    return {
      name: answer.label, 
      data: [answer.tally]
    };
  });

  $(containerId).highcharts({
    chart: {
      type: 'column',
      plotBackgroundColor: null,
      plotShadow: false,
    },
    colors: PT.colors,
    title: {
      text: inputSummary.label
    },
    tooltip: {
      headerFormat: '{point.series.name}',
      pointFormat: '<br><b>{point.y}</b>'
    },
    credits: {
      enabled: false
    },
    xAxis: {
      lineColor: 'transparent',
      tickWidth: 0,
      labels: {
        enabled: false
      }
    },
    yAxis: {
      allowDecimals: false,
      title: {
        text: ''
      }
    },
    plotOptions: {
      column: {
        allowPointSelect: true,
        cursor: 'pointer',
        pointPadding: .25,
        borderWidth: 0,
        dataLabels: {
          enabled: false,
        }
      }
    },
    series: series
  });
};

$(function(){
  dispatcher.subscribe('sharedataloaded', function(data){
    PT.populateImages(PT.responses, "#image-viz");
    PT.renderGoogleMap(data);
    PT.aggregate = PT.aggregateData(data);
  })
});
