function Out-MappedData
{
param(
    [parameter(Mandatory=$true,
    ValueFromPipeline=$true)]
[object[]]$data,
[ValidateScript({Test-Path $_ -PathType Container})] 
$Path = $env:temp,
$Height=800,
$Width= 800,
[switch]$group,
[string]$filename ='Data.html',
[switch]$quiet,
[switch]$circleicon)
BEGIN
{
    $Markers = "var markers = [`n"
    $count = 0
}

PROCESS
{
    ForEach ($Item in $data)
    {   $Name =$item.Name.Replace("`'","\'")
        $Markers += "    ['$Name',$($item.Latitude),$($Item.Longitude)]"
        $Markers += ",`n"
        $count++
    
    }
}
END
{
$markers = $markers.TrimEnd(",`n")
$Markers += "`n  ];`n"


$HTML = @"
<!DOCTYPE html>
<html>
  <head>
    <meta name="viewport" content="initial-scale=1.0, user-scalable=no">
    <meta charset="utf-8">
    <title>$filename</title>
    <style>
      html, body, #map-canvas {
        height: $($Height)px;
        width: $($Width)px;
        margin: 0px;
        padding: 0px
      }
    </style>
    <script src="https://developers.google.com/maps/documentation/javascript/examples/markerclusterer/markerclusterer.js"></script>
    <script src="https://maps.googleapis.com/maps/api/js?v=3.exp&sensor=false"></script>
    <script>
function initialize() {
  var bounds = new google.maps.LatLngBounds();
  var mapOptions = {
    mapTypeId: google.maps.MapTypeId.HYBRID,

  }
  var map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions);
  $Markers
  var datapoints = []

  for( i = 0; i < markers.length; i++ ) {
    var loc = new google.maps.LatLng(markers[i][1], markers[i][2]);

    var image = 'http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=' + (i + 1) + '|FF0000|000000';
    marker = new google.maps.Marker({
      position: loc,
"@
if($circleicon.ispresent)
    {
    $html += "icon: getCircle(),"
    }

if($group.isPresent)
    {
    $html += @"
      title: markers[i][0]
    });
      datapoints.push(marker);
      bounds.extend(loc);
  }
  
 var markerCluster = new MarkerClusterer(map, datapoints,
            {imagePath: 'https://developers.google.com/maps/documentation/javascript/examples/markerclusterer/m'});
"@
    }
else
    {
    $html += @"
    map: map,
    title: markers[i][0]
    });

    bounds.extend(loc);
    }
"@
    }
$html += @"
    

 
  if (markers.length > 1) {
    map.fitBounds(bounds);
  }
  else {
    map.setCenter(new google.maps.LatLng(markers[0][1],markers[0][2]));
    map.setZoom(4);
  }
}

function getCircle() {
  return {
    path: google.maps.SymbolPath.CIRCLE,
    fillColor: 'red',
    fillOpacity: 1,
    scale: 4,
    strokeColor: 'white',
    strokeWeight: .5
  };
}


google.maps.event.addDomListener(window, 'load', initialize);
    </script>
  </head>
  <body>
    <div id="map-canvas"></div><br>
    <p>Datapoints displayed: $count<br>
    </p>
  </body>
</html>
"@

Try {
    $HTML | Out-File "$Path\$filename" -Encoding ASCII -ErrorAction Stop
}
Catch {
    Write-Warning "Unable to save HTML at $Path\$filename because $_"
    Exit
}

if($quiet.ispresent -eq $false)
    {
    $output = "$Path\$filename"
    & $output
    }
}

}

