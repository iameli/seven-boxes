#
# Seven Boxes.
# Because I should never need more.
#
root = exports ? this
Seven = root.Seven = {}

delay = (time, func) -> Meteor.setTimeout func, time

# Model

Seven.Box = new Meteor.Collection "box"

Meteor.methods
  'setBox': (user, num, content) ->
    curBox = Seven.Box.findOne 
      user: user
      num: num
    newDoc = 
      user: user
      num: num
      content: content
    if curBox?
      Seven.Box.update {_id: curBox._id}, newDoc
    else
      Seven.Box.insert newDoc

# View

if Meteor.isClient
  curNum = null
  Meteor.startup ->
    #Wrangle accounts-ui a bit.
    Session.set("Meteor.loginButtons.dropdownVisible", true)
      
    #CodeMirror wrangling. When we close the lightbox, save.
    $('#Lightbox').on 'shown', ->
      Seven.codeMirror.refresh()
    $('#Lightbox').on 'hide', ->
      Meteor.call 'setBox', Meteor.user()._id, curNum, "\n" + Seven.codeMirror.getValue()
      
  #Upon double-clicking a box, show codemirror
  Template.box.events =
    'dblclick .box': (e) ->
      $('#Lightbox').modal('show')
      curNum = this.num
      Seven.codeMirror.setValue this.content.trim()
      
  #Logout link
  Template.main.events =
    'click #Logout': (e) ->
      Meteor.logout()
      Session.set("Meteor.loginButtons.dropdownVisible", true)
      return false
      
  #Privacy policy nonsense
  Template.login.policy = ->
    return Session.get 'displayPolicy'
  Template.login.events = 
    'click #ShowPolicy': ->
      Session.set 'displayPolicy', true
        
  #Repopulate the session variables that show the boxes after a change.
  Deps.autorun ->
    user = Meteor.user()
    if user?
      #This is a bit of a hack but CodeMirror doesn't like getting hidden
      #and called repeatedly so we just delete it and reinitialize it upon
      #every login.
      delay 0, ->
        $('#Lightbox').empty()
        Seven.codeMirror = CodeMirror $('#Lightbox')[0],
          mode: 'markdown'
      boxes = Seven.Box.find
        user: user._id
      myBoxes = {}
      boxes.forEach (box) ->
        Session.set "box_#{box.num}", box
        myBoxes[box.num] = true
      for num in ['1','2','3','4','5','6','7']
        if not myBoxes[num]
          Session.set "box_#{num}",
            num: num
            content: 'empty\n======'
        
  Template.main.box = (num) ->
    return Template.box(Session.get "box_#{num}")

# Controllers are for wimps