/* The MIT License (MIT)

Copyright (c) 2015 Yu Wang

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/


;(function ( $, window, document, undefined ) {

    $.fn.osmStaticMap = function(options){
        var opts = $.extend({}, $.fn.osmStaticMap.defaults, options);
        var markerList = [];

        var self = this;

        var long2tile = function(lon,zoom) { return (((lon+180)/360*Math.pow(2,zoom))); };

        var lat2tile = function(lat,zoom)  { return (((1-Math.log(Math.tan(lat*Math.PI/180) + 1/Math.cos(lat*Math.PI/180))/Math.PI)/2 *Math.pow(2,zoom))); };

        var lonLat2TilePixels = function(lon, lat, zoom){
            var x = long2tile(lon, zoom),
                y = lat2tile(lat, zoom),
                tx = Math.floor(x),
                ty = Math.floor(y),
                px = Math.floor((x-tx)*opts.tileSize),
                py = Math.floor((y-ty)*opts.tileSize);

            return {
                tilex: tx,
                tiley: ty,
                pixelx: px,
                pixely: py
            }
        };

        var getTile = function(zoom,x,y) {
            if(zoom>opts.maxZoom)
                zoom=opts.maxZoom;
            else if(zoom<0)
                zoom=0;
            return opts.url.replace('{x}',x).replace('{y}',y).replace('{z}',zoom);
        };

        var drawTileActiveProcessNumber = 0;
        var onAllTilesLoaded = function(){};
        var drawTile = function(ct, x, y, z, px, py){
            var t = new Image;
            drawTileActiveProcessNumber++;
            t.onload = function(){
                ct.drawImage(t, px, py);
                drawTileActiveProcessNumber--;
                if(drawTileActiveProcessNumber<=0){
                    onAllTilesLoaded();
                }
            };
            t.src = getTile(z, x, y);
        };

        var drawCircle = function(ct, color, x, y){
            ct.beginPath();
            ct.arc(x, y, opts.circleRadius, 0, 2*Math.PI, false);
            ct.fillStyle = color;
            ct.fill();
            ct.lineWidth = opts.circleStroleLineWidth;
            ct.strokeStyle = opts.circleStrokeStyle;
            ct.stroke();
        }

        var drawMap = function(ct, canvasWidth, canvasHeight){
            var margin=opts.margin;
            var maxLon=-180.0, maxLat=-90.0, minLon=180.0, minLat=90.0, zoom=opts.zoom;
            // 1. try to determine the maximum zoom;
            for(var mi in opts.markers){
                var points = opts.markers[mi].points;
                for(var pi in points){
                    if(points[pi].lon > maxLon) maxLon = points[pi].lon;
                    if(points[pi].lat > maxLat) maxLat = points[pi].lat;
                    if(points[pi].lon < minLon) minLon = points[pi].lon;
                    if(points[pi].lat < minLat) minLat = points[pi].lat;
                }
            }

            var leftTopCornor, rightBottomCornor;
            // if(maxLon != minLon && maxLat != minLat){
                for(var z=opts.maxZoom;z>=0;z--){
                    leftTopCornor = lonLat2TilePixels(minLon, maxLat, z);
                    rightBottomCornor = lonLat2TilePixels(maxLon, minLat, z);
                    var xspan = (rightBottomCornor.tilex - leftTopCornor.tilex)*opts.tileSize+
                                (rightBottomCornor.pixelx - leftTopCornor.pixelx),
                        yspan = (rightBottomCornor.tiley - leftTopCornor.tiley)*opts.tileSize+
                                (rightBottomCornor.pixely - leftTopCornor.pixely);
                    if(xspan+margin<canvasWidth && yspan+margin<canvasHeight){
                        zoom = z;
                        break;
                    }
                }
            // }

            // 2. draw base map;
            // 2.1 calculate x/y offset
            var xOffset = (canvasWidth/2 - xspan/2) - leftTopCornor.pixelx;
            var yOffset = (canvasHeight/2 - yspan/2) - leftTopCornor.pixely;
            var startTileX = leftTopCornor.tilex;
            var startTileY = leftTopCornor.tiley;
            if(xOffset > 0){
                var offsetTileNumber = Math.ceil(xOffset/opts.tileSize);
                startTileX = startTileX - offsetTileNumber;
                xOffset -= offsetTileNumber*opts.tileSize;
            }
            if(yOffset > 0){
                var offsetTileNumber = Math.ceil(yOffset/opts.tileSize);
                startTileY = startTileY - offsetTileNumber;
                yOffset -= offsetTileNumber*opts.tileSize;
            }

            // 2.2 draw base map tiles
            var tileX=startTileX, tileY=startTileY, drawPositionX=xOffset, drawPositionY = yOffset;
            do {
                // draw row by row
                tileX = startTileX;
                drawPositionX = xOffset;
                do {
                    // draw column by column
                    drawTile(ct, tileX, tileY, zoom, drawPositionX, drawPositionY);

                    tileX++;
                    drawPositionX+=opts.tileSize;
                } while(drawPositionX < canvasWidth);
                tileY++;
                drawPositionY+=opts.tileSize;
            } while(drawPositionY < canvasHeight);

            // 3. draw markers.
            onAllTilesLoaded = function(){
                for(var mi in opts.markers){
                    var color = opts.markers[mi].color;
                    var points = opts.markers[mi].points;
                    for(var pi in points){
                        var lon = points[pi].lon;
                        var lat = points[pi].lat;
                        var tilePixels = lonLat2TilePixels(lon, lat, zoom);
                        var x = (tilePixels.tilex-startTileX)*opts.tileSize + xOffset + tilePixels.pixelx;
                        var y = (tilePixels.tiley-startTileY)*opts.tileSize + yOffset + tilePixels.pixely;
                        drawCircle(ct, color, x, y);
                        markerList.push({data:points[pi], 'x':x, 'y':y});
                    }
                }

                // draw copyright notice
                ct.font = "bold 10px sans-serif";
                ct.textAlign = "right";
                ct.textBaseline = "bottom";
                ct.fillStyle = "#999999";
                ct.fillText(opts.copyrightNotice, canvasWidth-3, canvasHeight-3);
            };


        };

        var IsPointInsideMarker = function(px, py, marker){
            return (px-marker.x)*(px-marker.x)+(py-marker.y)*(py-marker.y) < opts.circleRadius*opts.circleRadius;
        }

        return this.each(function(){
            drawMap(this.getContext("2d"), this.width, this.height);
            if(opts.interactive){
                $(this).mousemove(function(e){
                    var px = e.offsetX, py = e.offsetY;
                    if(markerList.some(function(element, indix, array){
                        return IsPointInsideMarker(px, py, element);
                    })){    // if there is a marker under cursor
                        this.style.cursor = "pointer";
                    }
                    else{
                        this.style.cursor = "default";
                    }
                });
                $(this).click(function(e){
                    var px = e.offsetX, py = e.offsetY;
                    var hitMarkers = markerList.filter(function(e, i, arr){
                        return IsPointInsideMarker(px, py, e);
                    });
                    if(hitMarkers.length > 0){
                        opts.click(e, hitMarkers);
                    }
                });
            }
        });
    };

    $.fn.osmStaticMap.defaults = {
        zoom: 17,           // zoom level when there's only a single point
        tileSize: 256,      // tile size in pixels, don't change if unclear about it.
        markers: [{
            color: 'red',
            points: [{lon: -71.08755648136139,lat: 42.36059723560794}]
        }],
        url:'http://a.tile.openstreetmap.org/{z}/{x}/{y}.png',  // tile url pattern
        maxZoom:18,         // max zoom level when there are multiple points
        margin: 10,         // minimum margin at the border of the map
        circleRadius: 5,    // radius of the circle marker
        circleStroleLineWidth: 1,
        click: function(e, p){console.log(p)},
        interactive: false,
        copyrightNotice: "(c)OpenStreetMap Contributors",
        circleStrokeStyle: '#333333'
    };

})( jQuery, window, document );