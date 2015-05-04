Meteor.methods
  removePrevQeuery:(id)->
    PrevQueries.remove
      _id:id
    Venues.remove
      searchId:id