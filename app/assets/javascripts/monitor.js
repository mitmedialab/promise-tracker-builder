PT = PT || {};

PT.aggregatUrl = "http://dev.aggregate.promisetracker.org/";

PT.retrieveResponses = function(surveyId){
  var url = PT.aggregatUrl + "/surveys/" + surveyId + "/responses";  
  $.get(url, function(data){
    PT.responses = data.payload;
    dispatcher.dispatch('responsedataloaded', PT.responses)
  });
};

PT.renderGraph = function(data, containerId){
  // Setup Variables //
  var $container, height, width, margins, svg, graph, x, y, 
      xAxis, yAxis, xExtene, line, startLine, plotPoints;

  $container = $(containerId);
  $container.empty();
  height = 250;
  width = $container.width();
  margins = {
    x: 60,
    y: 40
  };

  svg = d3.select(containerId).append('svg')
      .attr('width', width)
      .attr('height', height);

  graph = svg.append('g')
      .attr("class", "graph-activity")
      .attr("transform", "translate(30, 20)");

  x = d3.time.scale().range([0, (width - margins.x)]);
  y = d3.scale.linear().range([(height - margins.y), 0]);

  xAxis = d3.svg.axis()
      .scale(x)
      .orient("bottom")
      .tickSize(height - margins.y)
      .tickPadding(10)
      .ticks(d3.time.day, 1)
      .tickFormat(d3.time.format('%d %b'));

  yAxis = d3.svg.axis()
      .scale(y)
      .orient("left")
      .tickSize(width - margins.x)
      .tickPadding(10)
      .ticks(5);

  startLine = d3.svg.line()
      .x(function(d) { return x(new Date(d.key)); })
      .y(height);

  line = d3.svg.line()
      .x(function(d) { return x(new Date(d.key)); })
      .y(function(d) { return y(d.values.length); });

  plotPoints = function(data){
    graph.append("path")
      .datum(data)
      .attr("class", "activity-line")
      .attr("d", startLine)
      .transition()
      .duration(700)
      .attr("d", line);

    graph.append("g")
        .attr("class", "data-points")
        .selectAll("circle")
      .data(data)
        .enter()
        .append("circle")
          .attr("class", "point")
          .attr("r", 5)
          .attr("cx", function(d) { return x(new Date(d.key)); })
          .attr("cy", height)
          .transition()
          .duration(700)
          .attr("cy", function(d) { return y(d.values.length); })
  };

  if(data.length > 0) {
    xExtent = d3.extent(data, function(d) { return new Date(d.key); });
  } else {
    xExtent = [new Date(Date.now()).setHours(0,0,0,0), new Date(Date.now()).setHours(0,0,0,0)];
  }
  x.domain([d3.time.day.offset(xExtent[0], -1), d3.time.day.offset(xExtent[1], 5)]);
  y.domain([0, d3.max(data, function(d) { return d.values.length; }) + 10 || 10])
  
  graph.append("g")
    .attr("class", "x axis")
    .attr("transform", "translate(0,0)")
    .call(xAxis);

  graph.append("g")
    .attr("class", "y axis")
    .attr("transform", "translate(0" + (width - margins.x) + ",0)")
    .call(yAxis);

  plotPoints(data);
};

PT.renderMonitorViz = function(data){
  dispatcher.subscribe('responsedataloaded', function(data){
    var responseCount = data.length;
    $(".response-count").html(responseCount);
    $(".graph-bar.current").css("width", responseCount / PT.campaign.submissions_target * 100);
    PT.responsesPerDay = d3.nest()
      .key(function(d) {
        var day = new Date(d.timestamp).setHours(0, 0, 0, 0)
        return new Date(day);
      })
      .entries(data);

    PT.renderGraph(PT.responsesPerDay, "#activity-graph");
    PT.populateImages(PT.responses, "#image-viz");
  });
};