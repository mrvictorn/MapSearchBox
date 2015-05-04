Meteor.publish 'prevqueries',()->
  PrevQueries.find
    owner: this.userId

Meteor.publish 'venues',()->
  Venues.find
    owner: this.userId

Meteor.startup ()->
  PrevQueries._ensureIndex
    "owner": 1
  Venues._ensureIndex
    "owner": 1
