(function(global) {
    "use strict;"

    /// constant
    var SF_LATITUDE = 42.2355854279;
    var SF_LONGITUDE = -71.5235686675;
//    var SF_LATITUDE = 37.7833;
//    var SF_LONGITUDE = -122.4167;

    /// global variable
    var g_map;
    var g_renderer = null;

    /**************************************************
     *             MapMath                            *
     **************************************************/
    function MapMath() {
    };

    /// Member
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
    APIClient.prototype.getFormParameters = APIClient_getFormParameters;                      // APIClient#getFormParameters

    /// Implementation
    function APIClient_executeAPI(method, path, success, failure) {
        var params = this.getFormParameters();
        var API_URI = path + "?" + $.param(params)
        console.log(API_URI);
        $.ajax({
                type: method,
                 url: API_URI,
             success: success,
             failure: failure
        });
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

    /**************************************************
     *                    Renderer                    *
     **************************************************/
    function Renderer() {
    };

    /// Member
    Renderer.prototype.drawMakers = Renderer_drawMakers;                                  // Renderer#drawMakers
    Renderer.prototype.drawResponse = Renderer_drawResponse;                              // Renderer#drawResponse
    Renderer.prototype.drawRangeRect = Renderer_drawRangeRect;                            // Renderer#drawRangeRect
    Renderer.prototype.drawMyLocation = Renderer_drawMyLocation;                          // Renderer#drawMyLocation
    Renderer.prototype.rangeRect = null;
    Renderer.prototype.myLocationMarker = null;

    /// Implementation
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

    $(function() {
        g_renderer = new Renderer();
        g_map = new google.maps.Map(
            document.getElementById("map"),
            { zoom: 13, mapTypeId: google.maps.MapTypeId.ROADMAP, center: new google.maps.LatLng(SF_LATITUDE, SF_LONGITUDE) }
        );
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
        g_renderer.drawMyLocation(SF_LATITUDE, SF_LONGITUDE)

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
                    // draw markers
                    var index = 0;
                    var colors = ["FF3333", "33FF33", "3333FF", "FFFF33", "33FFFF", "FF33FF", "FFFFFF", "333333"]
                    for (key in data) { g_renderer.drawMakers(data[key], colors[index++]); }
                    // draw response
                    g_renderer.drawResponse(uri, data);
                },
                function(error) {
                    console.log(error);
                }
            );
        });
    });
})((this || 0).self || global);
