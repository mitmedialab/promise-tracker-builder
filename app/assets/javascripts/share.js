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

PT.populateImages = function(imageUrlArray, containerId){
  var $container = $(containerId), image;

  imageUrlArray.forEach(function(url){
    image = '<img class="item"src="' + url + '">';
    $container.append(image);
  })
};

PT.renderImages = function(containerId){
  var $container = $(containerId);
  $container.imagesLoaded(function(){
    $container.masonry({
      itemSelector: ".item"
    })
  })
};

PT.renderGoogleMap = function(response){
  var markers = [];
  var attachMarkerClickEvent = function(marker, response){
    var image = null;
    for(var i=0,len=response.answers.length;i<len;i++){
      var answer = response.answers[i];
      switch(answer.type){
        case 'location':
          break;
        case 'image':
          if(answer.value)
          break;
        default:

      }
    }
    var infoWindow = new google.maps.InfoWindow({
      content: 
    })

  }

};
dispatcher.subscribe('responsedataloaded', PT.renderGoogleMap);