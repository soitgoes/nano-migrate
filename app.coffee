Path = require 'path'
Migrator = require "./migrator"

migrator = new Migrator 'http://admin:userssuck@localhost:5984/continuum', Path.join(__dirname, 'example')
migrator.updateIfNecessary()