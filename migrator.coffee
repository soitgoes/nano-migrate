fs = require 'fs'
nano = require 'nano'
path = require 'path'
crypto = require('crypto');
hasher = crypto.createHash('sha256');

class Migrator
  constructor: (@uri, @baseDirectory) ->
    console.log(@uri, @baseDirectory)
    @db = nano(@uri)

  updateIfNecessary: ->
    files = fs.readdirSync(@baseDirectory)
    console.log(files)

    for file in files
      id = "_design/" + path.basename(file, '.js')
        
      @db.get id, (err, doc) =>
        absFilePath = path.join(@baseDirectory, path.basename(file, '.js'))
        console.log(absFilePath)
        obj = require(absFilePath)
        
        views = {}
        for own name, view of obj
          if (view.map)
            view.map = view.map.toString()
          if (view.reduce)
            view.reduce = view.reduce.toString()
          views[name] = view

        console.log("id", id)
        console.log(views)
        hasher.update(JSON.stringify(views), 'utf8')
        hash = hasher.digest('hex')
        
        if (err)
          doc = {_id:id}
          doc.language = 'javascript'
          doc.hash = hash
          doc.views = views
          @db.insert doc, (err, ret) ->
            console.log(err)
            return 
        
        else if (doc && doc.hash != hash)
          doc.views = views
          doc.hash = hash
          @db.insert doc, (err, ret) ->
            console.log(err)



module.exports = Migrator
