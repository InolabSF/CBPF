(function(global) {
    "use strict;"

    /// constant
    var SF_LATITUDE = 37.7833;
    var SF_LONGITUDE = -122.4167;

    /// global variable
    var g_map;
    var g_marker = null;
    var g_rect = null;
    var g_dots = [];

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
    APIClient.prototype.executeGETCrimeData = APIClient_executeGETCrimeData;   // APIClient#executeGETCrimeData
    APIClient.prototype.executeGETSensorData = APIClient_executeGETSensorData; // APIClient#executeGETSensorData
    APIClient.prototype.executeGETWheelData = APIClient_executeGETWheelData;   // APIClient#executeGETWheelData

    /// Implementation
    function APIClient_executeAPI(method, path, params) {
        var API_URI = path + "?" + $.param(params)
        $.ajax({
                type: method,
                 url: API_URI,
             success: function(data) { console.log(data); },
             failure: function(error) { }
        });
    }

    function APIClient_executeGETCrimeData() {
    }

    function APIClient_executeGETSensorData() {
    }

    function APIClient_executeGETWheelData() {
    }










































    function createMarker(lat, long) {
        return new google.maps.Marker({
            position: new google.maps.LatLng(lat, long),
            map: g_map,
            title: ""
        });
    }

    function showJSON(json, uri) {
        $("#result").text(uri + "\n\n" + JSON.stringify(json, null, 2));
        drawDots(json);
    }

    function executeAPI() {
        var form = $("#form :input");
        var params = {};
        form.each(function() {
            params[this.name] = $(this).val();
        });
        params["lat"] = $("#lat").text().replace(/\s+/g, "");
        params["long"] = $("#long").text().replace(/\s+/g, "");
        params["api"] = $('input[name=api]:checked', '#form').val();
        var uri = params["api"]
        delete params["api"]
        uri += "?" + $.param(params)

        $.ajax({
                type: "GET",
                 url: uri,
         success: function(data) { showJSON(data, uri); },
         failure: function(error) { console.log(error); }
        });
    }

    function drawRect() {
        if (g_rect != null) { g_rect.setMap(null); }
        var form = $("#form :input");
        var params = {};
        form.each(function() {
            params[this.name] = $(this).val();
        });
        var radius = params["radius"]
        var lat = parseFloat($("#lat").text().replace(/\s+/g, ""));
        var long = parseFloat($("#long").text().replace(/\s+/g, ""));
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
        g_rect = rectangle
        g_rect.setMap(g_map);
    }

    function attachMessage(marker, msg) {
        google.maps.event.addListener(marker, 'click', function(event) {
            new google.maps.InfoWindow({
                content: msg
            }).open(marker.getMap(), marker);
        });
    }

    function drawDots(json) {
        for (var i = 0; i < g_dots.length; i++) {
            var dot = g_dots[i];
            dot.setMap(null);
        }
        g_dots = [];

        var datas = [];
        var api = $('input[name=api]:checked', '#form').val();
        switch (api) {
                case "/crime/data":
                        datas = json["crime_datas"];
                        break;
                case "/sensor/data":
                        datas = json["sensor_datas"];
                        break;
                case "/wheel/data":
                        datas = json["wheel_datas"];
                        break;
                default:
        }
        var pinColor = "00C000";
        var pinImage = new google.maps.MarkerImage("http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=%E2%80%A2|" + pinColor, new google.maps.Size(21, 34), new google.maps.Point(0,0), new google.maps.Point(10, 34));
        var pinShadow = new google.maps.MarkerImage("http://chart.apis.google.com/chart?chst=d_map_pin_shadow", new google.maps.Size(40, 37), new google.maps.Point(0, 0), new google.maps.Point(12, 35));
        for (var i = 0; i < datas.length; i++) {
            var lat = datas[i]["lat"];
            var long = datas[i]["long"];
            var dot = new google.maps.Marker({
                    position: new google.maps.LatLng(lat, long),
                    map: g_map,
                    title: "",
                    icon: pinImage,
                    shadow: pinShadow
            });
            var title = datas[i]["desc"];
            if (title != null) {
                attachMessage(dot, title)
            }
            dot.setMap(g_map);
        }
    }

    $(function() {

        g_map = new google.maps.Map(
            document.getElementById("map"),
            { zoom: 13, mapTypeId: google.maps.MapTypeId.ROADMAP, center: new google.maps.LatLng(SF_LATITUDE, SF_LONGITUDE) }
        );

        google.maps.event.addListener(g_map, 'click', function(event) {
            $("#lat").text(event.latLng.lat());
            $("#long").text(event.latLng.lng());
            if (g_marker != null) { g_marker.setMap(null); }
            g_marker = createMarker(event.latLng.lat(), event.latLng.lng());
            drawRect();
        });

        g_marker = createMarker(SF_LATITUDE, SF_LONGITUDE);

        $("#executeAPI").on("click", function() {
            var API = $('input[name=api]:checked', '#form').val();
            var params = {
                "lat" : $("#lat").text().replace(/\s+/g, ""),
                "long" : $("#long").text().replace(/\s+/g, ""),
            };
            executeAPI();
        });

        drawRect();
    });
})((this || 0).self || global);
