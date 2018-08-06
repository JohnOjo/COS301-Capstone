var markers = [];

function locationsRef() {
  return firebase.database().ref('/' + userID() + '/locations');
}

$(window).bind("load", function() {
  let succ = () => {
    initForemen();
    initMap();
  };
  let fail = () => {
  };
  retryUntilTimeout(succ, fail, 1000);
});

var foremen = [];
function changeSelection(checkbox) {
  for (var i = 0; i < foremen.length; i++) {
    if (foremen[i].key === checkbox.value) {
      if (checkbox.checked !== foremen[i].beingTracked) {
        foremen[i].beingTracked = checkbox.checked;
        updateMarkers();
      }
    }
  }
}

function createForemenSelectionButton(name, key) {
  result = '';
  result += '<div class="checkbox">';
  result += '<label><input type="checkbox" onchange="changeSelection(this)" checked value="' + key + '">' + name + '</label>';
  result += '</div>';
  
  return result;
}

function initForemen() {
  getWorkers((workersSnap) => {
    var foremenDiv = document.getElementById("foremen");
    workers = {};
    workersSnap.forEach((worker) => {
      const w = worker.val();
      const k = worker.key;
      if (w.type === "Foreman") {
        foremen.push({key: k, value: w, beingTracked: true});
        const name = w.name + " " + w.surname;
        foremenDiv.innerHTML += createForemenSelectionButton(name, k);
      }
    });
    displayForemanLocation();
  });
  requestLocations();
  setInterval(requestLocations, 1000 * 60 * 5);
}

function requestLocations() {
  for (var i = 0; i < foremen.length; i++) {
    if (foremen[i].beingTracked) {
      const reqRef = firebase.database().ref('/' + userID() + '/requestedLocations/' + foremen[i].key);
      reqRef.set({0: true});
    }
  }
}

var locations = [];
var map;
function initMap() {
  map = new google.maps.Map(document.getElementById('map'), {
    center: {lat: -25, lng: 28 },
    zoom: 14,
    mapTypeId: 'satellite'
  });
  locationLookup((data) => {
    var latLng = new google.maps.LatLng(data.lat, data.lon);
    map.setCenter(latLng);
    map.setZoom(11);
  });
}

function initials(name) {
  var f = name[0];
  var e = " ";
  for (var i = 0; i < name.length; i++) {
    if (name[i] === " " && i < name.length - 1) {
      e = name[i + 1];
    }
  }
  return f + e
}

function clearMarkers() {
  while (markers.length > 0) {
    let m = markers.pop()
    m.setMap(null);
  }
}

function updateMarkers() {
  clearMarkers();
  
  for (var i = 0; i < locations.length; i++) {
    const loc = locations[i].value;
    if (shouldShowForeman(locations[i].key)) {
      let date = displayDate(loc.date);
      var marker = new google.maps.Marker({
        position: loc.coord,
        map: map,
        title: loc.display,
        label: initials(loc.display)
      });
      marker.setTitle(loc.display + " - " + date);
      markers.push(marker);
    }
  }
}

function displayDate(timestamp) {
  let date = moment(new Date(timestamp * 1000));
  let today = moment(new Date());
  
  const fmtYear = date.format('YYYY') === today.format('YYYY') ? "" : "YYYY ";
  const fmtMonth = date.format('YYYY-MM') === today.format('YYYY-MM') ? "" : "MMM ";
  var fmtWeek = date.format('YYYY W') === today.format('YYYY W') ? "" : "ddd ";
  var fmtDay = date.format('YYYY-MM-DD') === today.format('YYYY-MM-DD') ? "" : "DD ";
  
  fmtWeek = (fmtMonth === "" ? fmtWeek : "");
  fmtDay = (fmtWeek === "" ? fmtDay : "");
  
  const fmt = fmtYear + fmtMonth + fmtWeek + fmtDay + "HH:mm";
  
  return date.format(fmt);
}

function shouldShowForeman(fID) {
  for (var i = 0; i < foremen.length; i++) {
    if (foremen[i].key === fID) {
      return foremen[i].beingTracked;
    }
  }
  return true;
}

var first = true;
function displayForemanLocation() {
  let locRef = firebase.database().ref('/' + userID() + '/locations');
  locRef.off();
  locRef.on('value', function(snapshot) {
    clearMarkers();
    locations = [];
    snapshot.forEach(function (child) {
      let loc = child.val();
      locations.push({value: loc, key: child.key});
      if (shouldShowForeman(child.key)) {
        let date = displayDate(loc.date);
        if (first) {
          first = false;
          map.setCenter(loc.coord);
          map.setZoom(15);
        }
        var marker = new google.maps.Marker({
          position: loc.coord,
          map: map,
          title: loc.display,
          label: initials(loc.display)
        });
        marker.setTitle(loc.display + " - " + date);
        markers.push(marker);
      }
    });
  });
}
