var PT = PT || {};

PT.colors = [
  "#f5be59", 
  "#66c6ba", 
  "#ea7669", 
  "#545757", 
  "#42847b", 
  "#efa9a3",
  "#e6e7e8",
  "#000000"
];

PT.extractImages = function(responses){
  var images = [];

  responses.forEach(function(response){
    response.answers.forEach(function(answer){
      if(answer.input_type == "image" && answer.value){
        images.push(answer.value);
      }
    })
  });

  return images;
};

PT.renderGoogleMap = function(serverResponse, containerId){
  var markers = [];
  var surveyDefinition = {};
  var map = null,
      infoWindow = null;
  var $container;

  var attachMarkerClickEvent = function(marker, response){
    var markerInfo = {
      id: response.id,
      image: null,
      displayableAnswers: {}
    };

    // 1. Browse through answers, extract image and responses
    for(var i=0,len=response.answers.length;i<len;i++){
      var answer = response.answers[i];
      switch(answer.input_type){
        case "location":
          break;
        case "image":
          if(typeof answer.value!=="undefined" && answer.value){
            markerInfo.image = answer.value;
          }
          break;
        default:
          markerInfo.displayableAnswers[surveyDefinition[answer.id]] = answer.value || "";
      }
    }

    // 2. Build marker popup template and attach listener
    google.maps.event.addListener(marker, "click", function(){
      infoWindow.setContent(HandlebarsTemplates["map_info_window"](markerInfo));
      infoWindow.open(map, marker);
    });
  };

  window.mapInit = function(){
    // Start initialization, create map
    var mapOptions = {
      zoom: 8,
      center: new google.maps.LatLng(-34.397, 150.644),
      scrollwheel: false
    };
    map = new google.maps.Map(document.getElementById(containerId), mapOptions);
    infoWindow = new google.maps.InfoWindow({
        content: ""
    });

    // Store survey definition
    var surveyInputs = serverResponse.survey.inputs;
    for(var i=0,len=surveyInputs.length;i<len;i++){
      var input = surveyInputs[i];
      surveyDefinition[input.id] = input.label;
    }

    // Create map markers
    var surveyResponses = serverResponse.responses;
    for(var i=0,len=surveyResponses.length;i<len;i++){
      var response = surveyResponses[i];

      // Find geo location
      var lat = null,
          lon = null;
      for(var j=0,len2=response.answers.length;j<len2;j++){
        var answer = response.answers[j];
        if(typeof answer.input_type!=="undefined" && answer.input_type=="location" && typeof answer.value!=="undefined" && typeof answer.value.lon!=="undefined"){
          lat = answer.value.lat;
          lon = answer.value.lon;
          break;
        }
      }
      if(lat==null || lon==null){
        if(response.locationstamp && response.locationstamp.lat !== "undefined" && response.locationstamp.long !== "undefined"){
          lat = response.locationstamp.lat;
          lon = response.locationstamp.lon;
        } else {
          continue; // Find if next response is a geolocation
        }
      }

      // Create marker
      if(lat && lon){
        var marker = new google.maps.Marker({
          map: map,
          position: new google.maps.LatLng(lat, lon)
        });
        markers.push(marker);

        attachMarkerClickEvent(marker, response);
      }
    }

    // Scale map viewport to include all markers
    var points = $.map(markers, function(a){
        return a.getPosition();
    });
    var bounds = new google.maps.LatLngBounds();
    for(var i=0;i<points.length;i++){
        bounds.extend(points[i]);
    }
    
    map.fitBounds(bounds);

    $("#map-tab").on("shown.bs.tab", function(){
      google.maps.event.trigger(map, "resize");
      map.fitBounds(bounds);
    });

  };

  // Load map script

  if(typeof google === "undefined"){
    var script = document.createElement("script");
    script.type = "text/javascript";
    script.src = "https://maps.googleapis.com/maps/api/js?v=3.exp&" +
        "callback=mapInit";
    document.body.appendChild(script);
  } else {
    window.mapInit();
  }
};

PT.aggregateData = function(payload){
  var survey = payload.survey,
  responses = payload.responses,
  answerAggregates = [];

  survey.inputs.forEach(function(input){
    var allAnswers = [];
    var tally;
    var inputSummary = {
      id: input.id,
      label: input.label,
      type: input.input_type,
      answers: []
    };

    responses.forEach(function(response){
      allAnswers.push(response.answers.filter(function(answer){
        return answer.id == input.id;
      })[0]);
    });

    switch(input.input_type){
      case "select1":
        input.options.forEach(function(option){
          tally = allAnswers.reduce(function(prev, current){
            return current.value == option ? prev + 1 : prev;
          }, 0);

          inputSummary.answers.push({label: option, tally: tally});
        })
        break;

      case "select":
        input.options.forEach(function(option){
          tally = allAnswers.reduce(function(acc, current){
            return current.value && current.value.indexOf(option) !== -1 ? acc + 1 : acc;
          }, 0);

          inputSummary.answers.push({label: option, tally: tally});
        })
        break;

      case "number":
      case "image":
      case "text":
        inputSummary.answers = allAnswers.reduce(function(acc, current){
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

PT.renderGallery = function(images, containerId, galleryName){
  var $container = $(containerId);

  $container.empty();
  images.forEach(function(image, index){
    var $a = $("<a/>");
    $image = $("<div/>", {class: "gallery-image"});
    $a.attr("href", image);
    $a.attr("data-lightbox", galleryName);
    $image.css("background", "url(" + image + ") no-repeat center center");
    $image.css("background-size", "cover");
    $a.append($image);
    $container.append($a);
  });
};

PT.renderText = function(stringArray, containerId){
  var $container = $(containerId);
  var $textBlock;

  stringArray.forEach(function(string, index){
    $textBlock = $("<span/>", {class: "text-viz"}).html(string);
    $textBlock.css("color", PT.colors[(index % PT.colors.length)]);
    $textBlock.css("font-size", Math.floor(Math.random(5) * 10 + 12) + "px");
    $container.append($textBlock);
  });
};

PT.renderMapForSummary = function($div, input, series){
  $div.empty();
  var $canvas = $('<canvas width="'+$div.innerWidth()+'" height="'+$div.innerHeight()+'"/>').appendTo($div);
  if(typeof series === 'undefined'){
    var series = null;
  }

  // Fit width and height to canvas's parent element (this can only be done in js)
  // var ct = $canvas[0].getContext('2d');
  // ct.canvas.width = $div.innerWidth();
  // ct.canvas.height = $div.innerHeight();

  // Find input's index in responses
  if(PT.responses.length <= 0) return;  // Quit if no response
  var inputIndex = PT.responses[0].answers.findIndex(function(element, index, array){
    return element.id == input.id
  });

  // Find location index
  var locationIndex = PT.responses[0].answers.findIndex(function(element, index, array){
    return element.input_type == 'location';
  });

  // Identify and fomat responses with location information
  var markerData = input.answers.map(function(element, index, array){
    return {
      color: PT.colors[index % PT.colors.length],
      points: PT.responses.filter(function(el, i, arr){
                if(el.answers[locationIndex] && el.answers[locationIndex].value && el.answers[locationIndex].value.lat || el.locationstamp.lon){
                  return el.answers[inputIndex].value == element.label;
                }
              }).map(function(el, i, arr){
                  return {
                    lon: el.answers[locationIndex].value.lon || el.locationstamp.lon,
                    lat: el.answers[locationIndex].value.lat || el.locationstamp.lat,
                    data: el
                  }
              })
    }
  }).filter(function(el){ // Remove input sets with no data points
    return el.points.length > 0;
  });

  if(markerData.length > 0){
    $canvas.osmStaticMap({
      url: "http://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png",
      circleRadius: 8,
      markers: markerData,
      interactive: true,
      click: function(e, p){
        console.log(p[0].data.data);
      }
    });
  }
};

PT.renderSummaries = function(aggregates, containerId, graphClass, callback){
  if(aggregates.length > 0 && PT.responses.length > 0){
    var $container = $(containerId);
    var $vizBox, $graphSquare;

    $container.empty();

    aggregates.forEach(function(input){
      $container.append(HandlebarsTemplates["input_viz"](input));

      switch(input.type){
        case "select":
        case "select1":
          $vizBox = $("#viz-input-" + input.id);
          $graphSquare = $("<div/>", {id: "graph-" + input.id, class: "graph-square " + graphClass});
          $vizBox.append($graphSquare);

          if(input.type == "select1"){
            PT.renderPieChart("#graph-" + input.id, input, true, false);
          } else {
            PT.renderColumnChart("#graph-" + input.id, input, true, false);
          };

          // Append map of color coded answers  
          var $map = $("<div/>", {class: "col-md-7 graph-square graph-map-"+input.id});
          $vizBox.append($map);
          PT.renderMapForSummary($map, input);

          break;

        case "location":
          // Render regular map here
          break;

        case "text":
          PT.renderText(input.answers, "#viz-input-" + input.id);
          break;

        case "number":
        case "date":
          // Render histogram?
          break;

        case "image":
          PT.renderGallery(input.answers, "#viz-input-" + input.id, "gallery-" + input.id);
          break;
      }
    })
  } else {
    $("#graph-placeholder").show();
  }

};

PT.renderGraphs = function(aggregates, containerId, graphClass){
  if(aggregates.length > 0 && PT.responses.length > 0){
    var $container = $(containerId), $graphSquare;

    $("#graph-placeholder").hide();
    $container.empty();

    aggregates.forEach(function(input){
      if(input.type == "select" || input.type == "select1"){
        $graphSquare = $(document.createElement("div"));

        $graphSquare.addClass(graphClass + " graph-square item");
        $graphSquare.attr("id", "graph-" + input.id)
        $container.append($graphSquare);

        switch(input.type){
          case "select1":
            PT.renderPieChart("#graph-" + input.id, input, false, true)
            break;

          case "select":
            PT.renderColumnChart("#graph-" + input.id, input, false, true)
            break;
        }
      }
    })

    // Show first item in graph carousel
    $(containerId + " .item").first().addClass("active");
    $(window).resize();
    if($(".carousel .item").length < 2){
      $(".carousel-control").hide();
    }
  }
};

PT.renderPieChart = function(containerId, inputSummary, titleDisabled, download){
  var data = inputSummary.answers.map(function(answer){
    return [answer.label, answer.tally];
  });

  !titleDisabled ? titleDisabled = inputSummary.label : titleDisabled = "";

  $(containerId).highcharts({
    chart: {
      plotBackgroundColor: null,
      plotShadow: false
    },
    colors: PT.colors,
    title: {
      text: titleDisabled
    },
    tooltip: {
      formatter: function(){
        return "<b>" + Highcharts.numberFormat(this.point.percentage, 1) + "%</b><br><span style='color: grey; font-size: .9em;'>(" + this.point.y + " " + I18n.t("campaigns.collect.responses.counting", {count: this.point.y}) + ")</span>"
      }
    },
    credits: {
      enabled: false
    },
    plotOptions: {
      pie: {
        allowPointSelect: true,
        cursor: "pointer",
        dataLabels: {
          enabled: true,
          format: "<b>{point.name}</b>: {point.percentage:.1f} %",
          style: {
              color: (Highcharts.theme && Highcharts.theme.contrastTextColor) || "black"
          }
        }
      }
    },
    series: [{
      type: "pie",
      name: "",
      data: data
    }],
    exporting: {
      enabled: download
    },
    navigation: {
      buttonOptions: {
        verticalAlign: "bottom",
        x: -60
      }
    }
  });
};

PT.renderColumnChart = function(containerId, inputSummary, titleDisabled, download){
  var series = inputSummary.answers.map(function(answer){
    return {
      name: answer.label, 
      data: [answer.tally]
    };
  });

  !titleDisabled ? titleDisabled = inputSummary.label : titleDisabled = "";

  $(containerId).highcharts({
    chart: {
      type: "column",
      plotBackgroundColor: null,
      plotShadow: false
    },
    colors: PT.colors,
    titleDisabled: {
      text: titleDisabled || inputSummary.label
    },
    tooltip: {
      headerFormat: "{point.series.name}",
      pointFormat: "<br><b>{point.y}</b>"
    },
    credits: {
      enabled: false
    },
    xAxis: {
      lineColor: "transparent",
      tickWidth: 0,
      labels: {
        enabled: false
      }
    },
    yAxis: {
      allowDecimals: false,
      title: {
        text: ""
      }
    },
    plotOptions: {
      column: {
        allowPointSelect: true,
        cursor: "pointer",
        pointPadding: .25,
        borderWidth: 0,
        dataLabels: {
          enabled: false,
        }
      }
    },
    series: series,
    exporting: {
      enabled: download
    },
    navigation: {
      buttonOptions: {
        verticalAlign: "bottom",
        x: -60
      }
    }
  });
};

// Profile page data section

$(function(){
  $(".carousel").carousel({
    pause: true,
    interval: false
  });

  // Hide carousel controls on first and last slide
  $(".carousel").on("slid.bs.carousel", function() {
    var $active = $(".carousel .item.active");
    $(window).resize();

    if($active.is(":first-child")){
      $(".carousel-control.left").fadeOut();
      $(".carousel-control.right").fadeIn();
    } else if($active.is(":last-child")) {
      $(".carousel-control.right").fadeOut();
      $(".carousel-control.left").fadeIn();
    } else {
      $(".carousel-control").fadeIn();
    }
  });

  $(document).ajaxSend(function(event, request, settings) {
    $(".ajax-loading").show();
  });

  $(document).ajaxComplete(function(event, request, settings) {
    $(".ajax-loading").hide();
  });
});
