(function(global) {
    "use strict;"

    /// constant
    var LATITUDE = 42.2355854279;
    var LONGITUDE = -71.5235686675;
//    var LATITUDE = 37.7833;
//    var LONGITUDE = -122.4167;
    var RADIUS = 50.0;
    var WHEEL_LOCATIONS = "wheel_locations";

    /// global variable
    var g_map;
    var g_renderer;


    /**************************************************
     *             MapMath                            *
     **************************************************/
    function MapMath() {
    };

    /// Member
    MapMath.prototype.getDistance = MapMath_getDistance;     // MapMath#getDistance
    MapMath.prototype.getLatDegree = MapMath_getLatDegree;   // MapMath#getLatDegree get latitude degree from latitude, longitude, mile
    MapMath.prototype.getLongDegree = MapMath_getLongDegree; // MapMath#getLongDegree get longitude degree from latitude, longitude, mile

    /// Implementation
    function MapMath_getDistance(lat1, long1, lat2, long2) {
        var y1 = lat1 * Math.PI / 180.0;
        var x1 = long1 * Math.PI / 180.0;
        var y2 = lat2 * Math.PI / 180.0;
        var x2 = long2 * Math.PI / 180.0;
        var earth_r = 6378140.0;
        var deg = Math.sin(y1) * Math.sin(y2) + Math.cos(y1) * Math.cos(y2) * Math.cos(x2 - x1);
        return earth_r * (Math.atan(-deg / Math.sqrt(-deg * deg + 1)) + Math.PI / 2) / 1000.0;
    }

    function MapMath_getLatDegree(lat, long, mile) {
        distance = MapMath_getDistance(lat, long, lat+1.0, long);
        return mile / distance;
    }

    function MapMath_getLongDegree(lat, long, mile) {
        distance = MapMath_getDistance(lat, long, lat, long+1.0);
        return mile / distance;
    }


    /**************************************************
     *              APIClient                         *
     **************************************************/
    function APIClient() {
    };

    /// Member
    APIClient.prototype.executeAPI = APIClient_executeAPI;                                    // APIClient#executeAPI
    APIClient.prototype.executeElevationAPI = APIClient_executeElevationAPI;                  // APIClient#executeElevationAPI
    APIClient.prototype.getFormParameters = APIClient_getFormParameters;                      // APIClient#getFormParameters
    APIClient.prototype.needsElevation = APIClient_needsElevation;                            // APIClient#needsElevation

    /// Implementation
    function APIClient_executeAPI(method, path, success, failure) {
        var params = this.getFormParameters();
        var API_URI = path + "?" + $.param(params)
        $.ajax({
                type: method,
                 url: API_URI,
             success: function(data) { success(data); },
             failure: function(error) { failure(error); }
        });
    }

    function APIClient_executeElevationAPI(json, success, failure) {
        var locations = json[WHEEL_LOCATIONS];
        if (locations == null || locations == undefined) { return; }

        // make elevation path
        var mapMath = new MapMath();
        var unit = 200;

        for (var i = 0; i < locations.length; i += unit) {
            var start = i;
            var end = (i + unit > locations.length) ? locations.length : i + unit;
            var previousLat = locations[i]["lat"];
            var previousLong = locations[i]["long"];
            var path = [];

            for (var j = start; j < end; j++) {
                var distance = mapMath.getDistance(previousLat, previousLong, locations[j]["lat"], locations[j]["long"]);
                if (distance < 0.05) { continue; }

                path.push(new google.maps.LatLng(locations[j]["lat"], locations[j]["long"]))
                previousLat = locations[j]["lat"];
                previousLong = locations[j]["long"];
            }
            if (path.length < 2) { continue; }
            var pathRequest = {
                "path" : path,
                "samples" : path.length
            };
            var elevationService = new google.maps.ElevationService()
            elevationService.getElevationAlongPath(
                pathRequest,
                function (results, status) {
                    if (status != google.maps.ElevationStatus.OK) {
                        failure(status);
                        return;
                    }
                    var elevations = results;
                    success(elevations);
                }
            );
        }
    }

    function APIClient_getFormParameters() {
        var form = $("#form :input");
        var params = {};
        form.each(function() {
            params[this.name] = $(this).val();
        });
        params["lat"] = $("#lat").text().replace(/\s+/g, "");
        params["long"] = $("#long").text().replace(/\s+/g, "");
        delete params["api"]
        return params;
    }

    function APIClient_needsElevation() {
        var uri = $('input[name=api]:checked', '#form').val();
        return uri == "/wheel/accel_torque";
    }


    /**************************************************
     *                    Renderer                    *
     **************************************************/
    function Renderer() {
    };

    /// Member
    Renderer.prototype.drawAllMakers = Renderer_drawAllMakers;                            // Renderer#drawAllMakers
    Renderer.prototype.drawMakers = Renderer_drawMakers;                                  // Renderer#drawMakers
    Renderer.prototype.drawResponse = Renderer_drawResponse;                              // Renderer#drawResponse
    Renderer.prototype.drawRangeRect = Renderer_drawRangeRect;                            // Renderer#drawRangeRect
    Renderer.prototype.drawMyLocation = Renderer_drawMyLocation;                          // Renderer#drawMyLocation
    Renderer.prototype.drawPolyline = Renderer_drawPolyline;                              // Renderer#drawPolyline
    Renderer.prototype.clearPolyline = Renderer_clearPolyline;                            // Renderer#clearPolyline

    Renderer.prototype.rangeRect = null;
    Renderer.prototype.myLocationMarker = null;
    Renderer.prototype.polylines = [];
    Renderer.prototype.markers = [];

    /// Implementation
    function Renderer_drawAllMakers(json) {
        for (var i = 0; i < this.markers.length; i++) {
            this.markers[i].setMap(null);
        }
        this.markers = [];

        var index = 0;
        var colors = ["FF3333", "33FF33", "3333FF", "FFFF33", "33FFFF", "FF33FF", "FFFFFF", "333333"]
        for (key in json) {
            if (key == WHEEL_LOCATIONS) { continue; }
            this.drawMakers(json[key], colors[index]);
            index = (index + 1) % colors.length;
        }
    }

    function Renderer_drawMakers(json, color) {
        var pinImage = new google.maps.MarkerImage(
            "http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=%E2%80%A2|" + color,
            new google.maps.Size(21, 34),
            new google.maps.Point(0,0),
            new google.maps.Point(10, 34)
        );
        var pinShadow = new google.maps.MarkerImage(
            "http://chart.apis.google.com/chart?chst=d_map_pin_shadow",
            new google.maps.Size(40, 37),
            new google.maps.Point(0, 0),
            new google.maps.Point(12, 35)
        );
        for (var i = 0; i < json.length; i++) {
            var lat = json[i]["lat"];
            var long = json[i]["long"];
            var marker = new google.maps.Marker({
                    position: new google.maps.LatLng(lat, long),
                    map: g_map,
                    title: "",
                    icon: pinImage,
                    shadow: pinShadow
            });
            this.markers.push(marker);
        }
    }

    function Renderer_drawResponse(path, json) {
        $("#result").text(path + "\n\n" + JSON.stringify(json, null, 2));
    }

    function Renderer_drawRangeRect(lat, long, radius) {
        if (this.rangeRect != null) { this.rangeRect.setMap(null); }

        lat = parseFloat(lat.replace(/\s+/g, ""));
        long = parseFloat(long.replace(/\s+/g, ""));
        var mapMath = new MapMath();
        var latOffset = mapMath.getLatDegree(lat, long, radius);
        var longOffset = mapMath.getLongDegree(lat, long, radius);

        var rectangle = new google.maps.Rectangle({
            strokeColor: '#FF0000',
            strokeOpacity: 0.8,
            strokeWeight: 2,
            fillColor: '#FF0000',
            fillOpacity: 0.35,
            map: g_map,
            bounds: new google.maps.LatLngBounds(
                new google.maps.LatLng(lat-latOffset, long-longOffset),
                new google.maps.LatLng(lat+latOffset, long+longOffset))
        });
        this.rangeRect = rectangle
        this.rangeRect.setMap(g_map);
    }

    function Renderer_drawMyLocation(lat, long) {
        if (this.myLocationMarker != null) { this.myLocationMarker.setMap(null); }
        this.myLocationMarker = new google.maps.Marker({
            position: new google.maps.LatLng(lat, long),
            map: g_map,
            title: ""
        });
    }

    function Renderer_clearPolyline() {
        // clear
        for (var i = 0; i < this.polylines.length; i++) {
            this.polylines[i].setMap(null);
        }
        this.polylines = [];
    }

    function Renderer_drawPolyline(elevations) {

        // draw
        var mapMath = new MapMath();
        for (var i = 0; i < elevations.length-1; i++) {
            var routePath = [
                new google.maps.LatLng(elevations[i].location.A, elevations[i].location.F),
                new google.maps.LatLng(elevations[i+1].location.A, elevations[i+1].location.F)
            ];
            var distance = mapMath.getDistance(elevations[i].location.A, elevations[i].location.F, elevations[i+1].location.A, elevations[i+1].location.F);
            var slope = Math.abs(
                //(elevations[i+1].elevation - elevations[i].elevation) / (distance * 1609.344) * 100
                (elevations[i+1].elevation - elevations[i].elevation) / (distance * 1609.344) * 1000
            );
            console.log(slope);
            var pathColor = "#000000";
            if (slope <= 5) { pathColor = "#3CB371"; }
            else if (slope <= 10) { pathColor = "#FFFF00"; }
            else if (slope <= 15) { pathColor = "#3366FF"; }
            else if (slope <= 20) { pathColor = "#FF0000"; }
            var polyline = new google.maps.Polyline({
                path: routePath,
                strokeColor: pathColor,
                strokeOpacity: 0.5,
                strokeWeight: 5,
                draggable: false,
                map: g_map
            });
            polyline.setMap(g_map);
            this.polylines.push(polyline)
        }
    }


    /**************************************************
     *                  Main                          *
     **************************************************/
    $(function() {
        // initialization
        g_renderer = new Renderer();
        g_map = new google.maps.Map(
            document.getElementById("map"),
            { zoom: 13, mapTypeId: google.maps.MapTypeId.ROADMAP, center: new google.maps.LatLng(LATITUDE, LONGITUDE) }
        );
        $("#radius").val(RADIUS);
        $("#lat").text(LATITUDE);
        $("#long").text(LONGITUDE);
        var params = (new APIClient()).getFormParameters();
        g_renderer.drawRangeRect(params["lat"], params["long"], params["radius"]);

        // click on the map
        google.maps.event.addListener(g_map, 'click', function(event) {
            // my location
            var lat = event.latLng.lat();
            var long = event.latLng.lng();
            $("#lat").text(lat);
            $("#long").text(long);
            g_renderer.drawMyLocation(lat, long)
            // range rect
            var params = (new APIClient()).getFormParameters();
            g_renderer.drawRangeRect(params["lat"], params["long"], params["radius"]);
        });
        g_renderer.drawMyLocation(LATITUDE, LONGITUDE)

        // click on the form
        $("#executeAPI").on("click", function() {
            // form datas
            var uri = $('input[name=api]:checked', '#form').val();
            // request
            var apiClient = new APIClient();
            apiClient.executeAPI(
                "GET",
                uri,
                function(data) {
                    // clear polyline
                    g_renderer.clearPolyline();

                    // draw markers
                    g_renderer.drawAllMakers(data);
                    // draw response
                    g_renderer.drawResponse(uri, data);

                    // elevation
                    if (!apiClient.needsElevation()) { return; }
                    apiClient.executeElevationAPI(
                        data,
                        function(data) {
                            //console.log(data);
                            g_renderer.drawPolyline(data);
                        },
                        function(error) {
                            console.log(error);
                        }
                    );
                },
                function(error) {
                    console.log(error);
                }
            );
        });
    });
})((this || 0).self || global);
