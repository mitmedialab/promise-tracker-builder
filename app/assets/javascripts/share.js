var PT = PT || {};

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
  var $container = $(containerId), images, image;
  var images = [];
  responses.forEach(function(response){
    response.answers.forEach(function(answer){

      if(answer.input_type == "image"){
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

PT.renderShareViz = function(){
  dispatcher.subscribe('responsedataloaded', function(data){
    PT.populateImages(PT.responses, "#image-viz");
  })
};