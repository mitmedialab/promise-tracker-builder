PT = PT || {};

PT.aggregatUrl = "http://dev.aggregate.promisetracker.org/";

PT.retrieveResponses = function(surveyId){
  var url = PT.aggregatUrl + "/surveys/" + surveyId + "/responses";  
  $.get(url, function(data){
    PT.responses = data;

    PT.minuteData = d3.nest()
      .key(function(d) {
        return new Date(d.timestamp).setSeconds(0);
      })
      .entries(data);
  });
};

PT.renderGraph = function(dataArray, containerId){

  // Setup Variables //

  var width, height, pointSize, format, x, y, svg, graph, parseDate, data;
  
  width = $(containerId).width();
  height = $(containerId).height();

  x = d3.time.scale()
      .range([0, width]);

  y = d3.scale.linear()
      .range([height - 20, 0]);

  svg = d3.select(containerId)
    .append("svg")
      .attr("width", width)
      .attr("height", height)
    .append("g")
      .attr("transform", "translate(10, 10)");   
    
  graph = svg.append('g')
      .attr("class", "graph")
      .attr("transform", "translate(0, 60)");

  // Axes //

  var xAxis = d3.svg.axis()
      .scale(x)
      .orient("bottom")
      .tickSize(height - 20)
      .tickPadding(20)
      // .tickFormat(d3.time.format('%b'));

  var yAxis = d3.svg.axis()
      .scale(y)
      .orient("left")
      .tickSize(width)
      .tickPadding(15)
      .ticks(5);

  var line = d3.svg.line()
      .x(function(d,i) { return x(new Date(parseInt(d.key)); })
      .y(function(d) { return y(d.values.length); });

  var startLine = d3.svg.line()
      .x(function(d,i) { return x(new Date(d.key)); })
      .y(height);

    
  // Legend //

  // var renderLegend = function(){
  //   var series = [
  //     {name: "Your usage", colorClass: "statement"},
  //     {name: "Average Arcadia member usage", colorClass: "average"}
  //   ];

  //   var legendPos;
  //   if(threshold){
  //     legendPos = {height: 40, xPos: 150, yPos: function() {return 10;}};
  //   } else {
  //     legendPos = {height: 60, xPos: 0, yPos: function(i) {return 20 * i;}};
  //   }

  //   var legendBox = svg.append('g')
  //       .attr("class", "legend")
  //       .attr("transform", "translate(0, 10)")
  //       .attr("height", legendPos.height)
  //       .attr("width", 200);

  //   legendBox.selectAll('g')
  //       .data(series)
  //     .enter().append('circle')
  //       .attr("class", function(d) { return "point " + d.colorClass; })
  //       .attr("r", pointSize)
  //       .attr("stroke-width", pointSize / 1.5)
  //       .attr("cy", function(d, i) { return legendPos.yPos(i); })
  //       .attr("cx", function(d,i) { return legendPos.xPos * i; });

  //   legendBox.selectAll('g')
  //       .data(series)
  //     .enter().append('text')
  //       .attr("x", function(d,i) { return legendPos.xPos * i + 20; } )
  //       .attr("y", function(d, i) { return legendPos.yPos(i) + 5; })
  //       .text(function(d) { return d.name; });
  //   };


    // Data points //  

    var plotPoints = function(dataArray){
      // graph.append("path")
      //     .datum(dataArray)
      //     .attr("class", "line")
      //     .attr("d", startLine)
      //     .transition()
      //     .duration(700)
      //     .attr("d", line);

      graph.append('g')
          .attr("class", "data-points")
          .selectAll('circle')
        .data(dataArray)
          .enter()
          .append('circle')
          .attr("class", "point")
          .attr("cx", function(d){return x(new Date(d.key));})
          .attr("r", pointSize)
          .attr("stroke-width", pointSize / 1.5)
          .transition()
          .duration(700)
          .attr("cy", function(d) { return y(d.values.length);});
    };


    // Tooltip //

    // var toolTip = d3.tip()
    //     .attr('class', 'd3-tip')
    //     .offset([-10, 0])
    //     .html(function(d) { return d.kwh + " KWH"; });


    // Fetch data and render graph //
       
     // Set domain 
      var xExtent = d3.extent(dataArray, function(d){return d.key;});
      x.domain([new Date(xExtent[0]), new Date(xExtent[0])]);
      y.domain([0, d3.max(dataArray, function(d) { return d.values.length })]);


      // Create axes
      graph.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0, 0)")
        .call(xAxis);

      graph.append("g")
          .attr("class", "y axis")
          .attr("transform", "translate(" + width + ", 0)")
          .call(yAxis);
        // .append("text")
        // .text("KWH")
        //   .attr("x", (-width -40))
        //   .attr("y", -10)
        //   .attr("class", "legend");

      // // Plot data    
      plotPoints(PT.minuteData);
    
      // Add legend & tooltip
      // renderLegend();
      // graph.call(toolTip);
};