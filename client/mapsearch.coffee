Meteor.startup ()->
  GoogleMaps.load()
  
Template.mapSearch.helpers
  mapSearchOptions: ()->
    if GoogleMaps.loaded() 
      aCenter = if Session.get 'mapCenter' then Session.get 'mapCenter' else new google.maps.LatLng 35.6995553,139.7162245
      return {
          center: aCenter
          zoom: 11
        } 
  searchDisabled: ()->
    'disabled' unless Session.get 'isMapReady'

Template.mapSearch.onCreated ()->
  GoogleMaps.ready 'mapSearch', (map)->
    Meteor.geoCoder = new google.maps.Geocoder()
    Meteor.venueMarkers =  new MarkersCtrl 'mapSearch'
    Meteor.geoCoder.geocode address:Meteor.settings.public.baseLocation,(res,status) -> 
      if status == google.maps.GeocoderStatus.OK 
        center = res[0].geometry.location 
      else 
        center = new google.maps.LatLng 35.6995553,139.7162245
      Session.set 'mapCenter', {lat: center.lat(), lng: center.lng()}
    Session.set 'isMapReady', true

Template.mapSearch.events
  'submit': (evt) ->
    evt.preventDefault()
    sQuery = evt.target.search.value.trim()
    return unless sQuery
    map = GoogleMaps.maps.mapSearch.instance
    bounds = map.getBounds()
    center = map.getCenter()
    zoom = map.getZoom()
    ne = bounds.getNorthEast()
    sw = bounds.getSouthWest()
    mapWidth = geo.getDistanceBetweenPoints {lat:ne.lat(),lng:ne.lng()}, {lat:ne.lat(),lng:sw.lng()}
    mapHeight = geo.getDistanceBetweenPoints {lat:ne.lat(),lng:ne.lng()}, {lat:sw.lat(),lng:ne.lng()}
    radius = Math.ceil(Math.min(mapWidth,mapHeight) / 2)
    radius = if radius < 100000 then radius else 100000 
    fourSquare.searchVenuesNear {lat:center.lat(),lng:center.lng()},radius,sQuery,(error,result)->
      #TODO show err info on client
      return if error or result.length == 0
      doc =
        name: sQuery
        position:
          lat:center.lat()
          lng:center.lng()
        radius: radius
        zoom: zoom
      idNewQ = PrevQueries.insert doc, (err,res)->
        unless err
          Session.set 'currSearchId', idNewQ
          addVenue = (doc) ->
            newV = 
              searchId: idNewQ
              name: doc.name
              address: doc.location.address
              city: doc.location.city
              position:
                lat: doc.location.lat
                lng: doc.location.lng
              category: doc.categories[0]
            Venues.insert newV, (err,res) ->
            return
          addVenue doc for doc in result
      return
    return

