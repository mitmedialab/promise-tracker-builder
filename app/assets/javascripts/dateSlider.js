(function($){
  $.fn.dateSlider = function(min, max, start, end){
    var getDay = function(timestamp){
      return (new Date(parseInt(timestamp))).setHours(0,0,0,0) / 1000;
    };

    this.slider({
      range: true,
      min: getDay(min),
      max: getDay(max),
      step: 86400,
      values: [getDay(start), getDay(end)]
    });
  };

}(jQuery));