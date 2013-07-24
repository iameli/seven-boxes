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
  user = 'default' # Eventually we'll support multiple users.
  curNum = null
  Meteor.startup ->
    Seven.codeMirror = CodeMirror.fromTextArea $('#Code')[0],
      mode: 'markdown'
    $('#Lightbox').on 'shown', ->
      Seven.codeMirror.refresh()
    $('#Lightbox').on 'hide', ->
      Meteor.call 'setBox', user, curNum, "\n" + Seven.codeMirror.getValue()
  Template.box.events =
    'dblclick .box': (e) ->
      $('#Lightbox').modal('show')
      curNum = this.num
      Seven.codeMirror.setValue this.content.trim()
        
      
  Deps.autorun ->
    boxes = Seven.Box.find
      user: user
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
    
  Template.box.getBox = (num) ->
    return Seven.myBoxes[num].content

# Controllers are for wimps