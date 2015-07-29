FoldernameTabs = null
log = null
reloader = null

pkgName = "foldername-tabs"

module.exports = new class Main
  subscriptions: null
  foldernameTabs: null
  config:
    maxLength:
      title: "Maximum path length"
      type: "integer"
      default: "20"
      description: "Allowed length of a path, if set to 0, will not shorten the path"

    folderLength:
      title: "Maximum folder length"
      type: "integer"
      default: "0"
      description: "Allowed length of a single folder, if set to 0, will not shorten the folder"
    mfpIdent:
      title: "Multi-folder project identifier"
      type: "integer"
      default: "0"
      description: "length of the project identifier, if set to 0 will use numbers instead"
    debug:
      type: "integer"
      default: 0
      minimum: 0

  activate: ->
    if atom.inDevMode()
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
          FoldernameTabs ?= require "./#{pkgName}"
          @foldernameTabs = new FoldernameTabs
        catch
          log "loading core failed"
      # make sure it activates only after the tabs package
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
