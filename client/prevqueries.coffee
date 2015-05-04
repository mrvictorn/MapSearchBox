Template.previousQueries.helpers
  prevQueries: ()->
    PrevQueries.find()
  selected: ()->
    if Session.equals("currSearchId",@_id) then "selected" else ''
     
Template.previousQueries.events
  'click .pQueryDelete': (evt)->
    Meteor.call 'removePrevQeuery', @_id

  'click .pQueryLine': (evt)->
    if Session.get('currSearchId') isnt @_id
      Meteor.venueMarkers.removeAllMarkers()
      Session.set 'currSearchId', @_id
      GoogleMaps.maps.mapSearch.instance.setCenter @position
      GoogleMaps.maps.mapSearch.instance.setZoom @zoom    
