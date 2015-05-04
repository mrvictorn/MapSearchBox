if Meteor.isClient  
  @fourSquare=
    searchVenuesInBounds:(bounds,query,callback)->
      Meteor.call 'searchVenuesInBounds',bounds,query,callback 
    searchVenuesNear:(point,radius,query,callback)->
      Meteor.call 'searchVenuesNear',point,radius,query,callback

if Meteor.isServer
  class @Foursquare 
    constructor:(aId,aSecret,aAuthOnly = false)->
      @config = 
        id:aId
        secret:aSecret
        authOnly: aAuthOnly 
    _toFourSquare:(LatLng)->
        ''+LatLng.lat+','+LatLng.lng
    searchVenuesInBounds:(bounds,query,callback)->
      #check bounds,Object
      #check query,String
      if (@config.authOnly && !@userId)
        throw new Meteor.Error 'Permission denied' 
      query = 
        client_id: @config.id,
        client_secret: @config.secret,
        v: 20130815
        sw: @_toFourSquare bounds.getSouthWest() ## Fix caller to json
        ne: @_toFourSquare bounds.getNorthEast() ## parameters !Gmaps objects
        intent:'browse'
      _getVenues = (err,res) ->
        if err then callback(err)
        callback err,res.data.response.venues if res.data and res.data.response and res.data.response.venues 
      result = HTTP.get 'https://api.foursquare.com/v2/venues/search', 
        params: query
        timeout: 20000
      ,
        _getVenues
    searchVenuesNear:(point,radius,searchquery)->
      if (@config.authOnly && !@userId)
        throw new Meteor.Error 'Permission denied' 
      query = 
        client_id: @config.id,
        client_secret: @config.secret,
        v: 20130815
        ll: @_toFourSquare point
        radius: radius
        intent:'browse'
        query: searchquery
      getVenues =(callback)->  
        _getVenues = (err,res) ->
          if err then callback(err)
          callback err,res.data.response.venues if res.data and res.data.response and res.data.response.venues 
        result = HTTP.get 'https://api.foursquare.com/v2/venues/search', 
          params: query
          timeout: 20000
        ,
          _getVenues
      retVenues = Meteor.wrapAsync getVenues
      return retVenues()

  @fourSquare = new Foursquare Meteor.settings.fourSquareKey, Meteor.settings.fourSquareSecret
  Meteor.methods
    searchVenuesInBounds:(bounds,query,callback)->
      fourSquare.searchVenuesInBounds bounds,query,callback
    searchVenuesNear:(point,radius,query,callback)->
      fourSquare.searchVenuesNear point,radius,query,callback

