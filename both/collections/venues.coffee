Schemas.Venues = new SimpleSchema
  searchId:
    type: String
    regEx: SimpleSchema.RegEx.Id
  owner: 
    type: String
    regEx: SimpleSchema.RegEx.Id
    autoValue: ->
      if this.isInsert
        Meteor.userId()
  name:
    type: String
  city:
    type: String
    optional: true
  address:
    type: String
    optional: true
  position:
    type: Schemas.LatLng
  category:
    type:Object
    blackbox: true # all what we get, we write  

@Venues = new Meteor.Collection 'venues'
Venues.attachSchema Schemas.Venues

if Meteor.isServer
  Venues.allow
    'insert': (userId,doc)->
      true
    'remove': (userId, doc, fieldNames, modifier)->
      true if userId is doc.owner
    'update': (userId,doc)->
      true if userId is doc.owner

