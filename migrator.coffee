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
        console.log(@baseDirectory, file)
        absFilePath = path.join(@baseDirectory, file)
        obj = JSON.parse(fs.readFileSync(absFilePath, 'utf8'))
        views = JSON.stringify(obj)
        console.log("id", id)
        console.log(views)
        hasher.update(views, 'utf8')
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
