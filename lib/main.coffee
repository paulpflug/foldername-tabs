FoldernameTabs = null
log = null
reloader = null

pkgName = "foldername-tabs"

module.exports = new class Main
  subscriptions: null
  foldernameTabs: null
  config:
    debug:
      type: "integer"
      default: 0
      minimum: 0

  activate: ->
    setTimeout (->
      reloaderSettings = pkg:pkgName,folders:["lib","styles"]
      try
        reloader ?= require("atom-package-reloader")(reloaderSettings)
      catch

      ),500
    unless log?
      log = require("atom-simple-logger")(pkg:pkgName,nsp:"main")
      log "activating"
    unless @foldernameTabs?
      log "loading core"
      load = =>
        try
          FoldernameTabs = require "./foldername-tabs"
          @foldernameTabs = new FoldernameTabs
        catch
          log "loading core failed"
          @foldernameTabs = new FoldernameTabs
      if atom.packages.isPackageActive("tabs")
        load()
      else
        @onceActivated = atom.packages.onDidActivatePackage (p) =>
          if p.name == "tabs"
            load()
            @onceActivated.dispose()


  deactivate: ->
    log "deactivating"
    @onceActivated?.dispose?()
    @foldernameTabs?.destroy?()
    @foldernameTabs = null
    log = null
    FoldernameTabs = null
    reloader?.dispose()
    reloader = null
