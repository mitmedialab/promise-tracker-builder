var PT = PT || {};

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

  } else {
    $("#graph-placeholder").show();
  }

};