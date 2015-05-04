Template.searchResults.events
  'click #btnExport' : ()->
    currSearchId = Session.get 'currSearchId'
    rawData = Venues.find({searchId:currSearchId},{fields:{name:1,city:1,address:1,position:1,_id:0}}).fetch()
    _order = (el)->
      el.lat = el.position.lat
      el.lng = el.position.lng
      delete el.position
    _order e for e in rawData 
    csv = convert2csv 
      data:rawData 
      fields:['name','city','address','lat','lng']
      fieldNames:['Name', 'City', 'Street Address', 'Latitude', 'Longitude']  
    blob = new Blob [csv],{type: "text/plain;charset=utf-8;",}
    qName = PrevQueries.findOne({_id:currSearchId}).name
    saveAs blob, "#{qName}-venues.csv"    

@venueSearchResults = (searchId)->
  Venues.find({searchId:searchId})  

Template.searchResults.helpers
  numFoundVenues: ()->
    venueSearchResults(Session.get('currSearchId')).count()
  foundVenues: ()->
    currVenues = venueSearchResults(Session.get('currSearchId'))
    currVenues.observe 
      added: (doc) ->
        icon = "#{doc.category.icon.prefix}bg_32#{doc.category.icon.suffix}"
        m = Meteor.venueMarkers?.addMarker doc._id,doc.position,doc.name,icon
        infowindow = new google.maps.InfoWindow
          content: doc.name
          size: new google.maps.Size(50,50)
        google.maps.event.addListener m, 'click', ()->
          infowindow.open Meteor.venueMarkers.getMap(),m
      removed: (doc) ->
        Meteor.venueMarkers?.removeMarker doc._id
    return currVenues
