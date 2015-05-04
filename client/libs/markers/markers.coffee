class @MarkersCtrl
  markers: {}
  constructor: (@mapName)->
  removeAllMarkers: ()->
    @_removeMarker m,i for i,m of @markers
    return
  getMap:()->
    GoogleMaps.maps[@mapName].instance
  addMarker: (id,pos,name,icon)->
    marker = new google.maps.Marker
      animation: google.maps.Animation.DROP
      position: new google.maps.LatLng pos.lat,pos.lng
      map: @getMap()
      icon: icon
      name: name
      id: id
    @markers[id] = marker
    return marker
  _removeMarker: (m,i) =>
    return unless m 
    m.setMap(null)
    google.maps.event.clearInstanceListeners m
    delete @markers[i]
  removeMarker: (i) =>
    @_removeMarker @markers[i],i 
    return