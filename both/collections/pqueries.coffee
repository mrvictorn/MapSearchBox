Schemas.LatLng = new SimpleSchema
  lat:
    type: Number
    decimal: true
  lng:
    type:Number
    decimal: true


Schemas.PrevQueries = new SimpleSchema
  name:
    type: String
  position:
    type: Schemas.LatLng
  radius:
    type: Number
  zoom:
    type: Number
  date:
    type: Date
    autoValue: ->
      new Date()
  owner: 
    type: String
    regEx: SimpleSchema.RegEx.Id
    autoValue: ->
      if @isInsert
        Meteor.userId()

@PrevQueries = new Meteor.Collection 'prevquery'

PrevQueries.attachSchema Schemas.PrevQueries
if Meteor.isServer
  PrevQueries.allow
    'insert': (userId,doc)->
      true
    'remove': (userId, doc, fieldNames, modifier)->
      true if userId is doc.owner
    'update': (userId,doc)->
      true if userId is doc.owner
