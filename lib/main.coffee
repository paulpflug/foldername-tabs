FoldernameTabs = null

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
    filenameFirst:
      title: "Filename first"
      type: "boolean"
      default: false
      description: "Puts the filename above the foldername"
    debug:
      type: "integer"
      default: 0
      minimum: 0
  debugger: -> ->
  debug: ->
  consumeDebug: (debugSetup) =>
    @debugger = debugSetup(pkg: pkgName)
    @debug = @debugger "main"
    @debug "debug service consumed", 2
  consumeAutoreload: (reloader) =>
    reloader(pkg:pkgName,folders:["lib/","styles/"])
    @debug "autoreload service consumed", 2
  activate: ->
    unless @foldernameTabs?
      @debug "loading core"
      load = =>
        FoldernameTabs ?= require "./foldername-tabs"
        @foldernameTabs = new FoldernameTabs(@debugger)
      # make sure it activates only after the tabs package
      if atom.packages.isPackageActive("tabs")
        load()
      else
        @onceActivated = atom.packages.onDidActivatePackage (p) =>
          if p.name == "tabs"
            load()
            @onceActivated.dispose()


  deactivate: ->
    @debug "deactivating"
    @onceActivated?.dispose?()
    @foldernameTabs?.destroy?()
    @foldernameTabs = null
    FoldernameTabs = null
