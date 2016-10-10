sep = require("path").sep
abbreviate = require "abbreviate"
log = () ->

{CompositeDisposable} = require 'atom'
paths = {}

# Parses a string path into an object containing the shortened foldername
# and filename
parsePath = (path) ->
  result = {}
  relativePath = atom.project.relativizePath path
  if relativePath?[0]? # within a project folder
    splitted = relativePath[1].split(sep)
  else
    splitted = path.split(sep)
  result.filename = splitted.pop()
  folderLength =  atom.config.get("foldername-tabs.folderLength")
  splitted = splitted.map (string) ->
    if folderLength > 0
      return abbreviate string, {
        length: folderLength
        keepSeparators: true
        strict: false
      }
    else
      return string
  if splitted.length > 0
    lastFolder = splitted.pop()
  else
    lastFolder = ""
  if relativePath?[0]? # within a project folder
    projectPaths = atom.project.getPaths()
    pathIdentifier = ""
    if projectPaths.length > 1 # multi-folder project
      mfpIdent =  atom.config.get("foldername-tabs.mfpIdent")
      if mfpIdent <= 0
        pathIdentifier += "#{projectPaths.indexOf(relativePath[0])+1}"
      else
        pathIdentifier += abbreviate relativePath[0].split(sep).pop(), {
          length: mfpIdent
          keepSeparators: true
          strict: false
        }
      pathIdentifier += sep if lastFolder
    result.foldername = pathIdentifier
  else # outside of project
    splitted.shift() # remove empty entry
    result.foldername = sep
  if splitted.length > 0 # there are some folders
    maxLength =  atom.config.get("foldername-tabs.maxLength")
    if maxLength > 0 # there is a space limitation
      maxLength -= lastFolder.length+4
      maxLength -= mfpIdent+1 if relativePath?[0]? and mfpIdent
      if maxLength > 0 # there is room for more information
        if relativePath?[0]? and splitted[0].length < maxLength # add first folder within project
          maxLength -= splitted[0].length
          result.foldername += splitted.shift()+ sep
        remaining = ""
        while splitted.length > 0
          current = splitted.pop()
          if maxLength > current.length+1
            maxLength -= current.length+1
            remaining = current + sep + remaining
          else
            break
        remaining += sep if remaining.length > 0
        if splitted.length > 0
          result.foldername += "..."+sep+remaining
        else
          result.foldername += remaining
      else # no space left
        result.foldername += "..." + sep
    else # no space limitation
      result.foldername += splitted.join(sep) + sep
  result.foldername += lastFolder
  return result

processAllTabs = (revert=false)->
  log "processing all tabs, reverting:#{revert}"
  paths = []
  paneItems = atom.workspace.getPaneItems()
  for paneItem in paneItems # get the unique paths of all opened files
    if paneItem.getPath?
      path = paneItem.getPath()
      if path? and paths.indexOf(path) == -1
        paths.push path
  log "found #{paths.length} different paths of
    total #{paneItems.length} paneItems",2
  for path in paths # process all opened paths
    tabs = atom.views.getView(atom.workspace).querySelectorAll "ul.tab-bar>
      li.tab[data-type='TextEditor']>
      div.title[data-path=\"#{path.replace(/\\/g,"\\\\").replace(/\"/g,"\\\"")}\"]"
    log "found #{tabs.length} tabs for #{path}",2
    for tab in tabs # if there are several tabs per path
      container = tab.querySelector "div.foldername-tabs"
      if container? and revert # removing all made changes
        log "reverting #{path}",2
        tab.removeChild container
        tab.innerHTML = path.split(sep).pop()
      else if not container? and not revert
        log "applying #{path}",2
        paths[path] ?= parsePath path
        tab.innerHTML = ""
        container = document.createElement("div")
        container.classList.add "foldername-tabs"
        filenameElement = document.createElement("span")
        filenameElement.classList.add "file"
        if paths[path].foldername == ""
          filenameElement.classList.add "file-only"
        filenameElement.innerHTML = paths[path].filename
        container.appendChild filenameElement
        if paths[path].foldername != ""
          foldernameElement = document.createElement("span")
          foldernameElement.classList.add "folder"
          foldernameElement.innerHTML = paths[path].foldername
          filenameFirst = atom.config.get("foldername-tabs.filenameFirst")
          if filenameFirst
            container.appendChild foldernameElement
          else
            container.insertBefore foldernameElement, filenameElement
        tab.appendChild container
  return !revert


module.exports =
class FoldernameTabs
  disposables: null
  processed: false
  constructor: (logger) ->
    log = logger "core"
    @processed = processAllTabs()
    unless @disposables?
      @disposables = new CompositeDisposable
      @disposables.add atom.workspace.onDidAddPaneItem -> setTimeout processAllTabs, 10
      @disposables.add atom.workspace.observePanes (pane) =>
        processAllTabs()
        disposables = new CompositeDisposable
        #disposable1 = pane.onDidAddItem -> setTimeout processAllTabs, 10
        disposable3 = pane.onDidRemoveItem -> setTimeout processAllTabs, 10
        disposable4 = pane.onDidMoveItem -> setTimeout processAllTabs, 10
        disposable2 = pane.onDidDestroy ->
          disposables.dispose() if disposables.disposables?
        disposables.add disposable2,disposable3,disposable4
        @disposables.add disposable2,disposable3,disposable4
      #@disposables.add atom.workspace.onDidAddPaneItem  ->
      #  setTimeout processAllTabs, 10
      #@disposables.add atom.workspace.onDidDestroyPaneItem ->
      #  setTimeout processAllTabs, 10
      @disposables.add atom.commands.add 'atom-workspace',
      'foldername-tabs:toggle': @toggle
      @disposables.add atom.config.observe("foldername-tabs.mfpIdent", @repaint)
      @disposables.add atom.config.observe("foldername-tabs.folderLength", @repaint)
      @disposables.add atom.config.observe("foldername-tabs.maxLength", @repaint)
      @disposables.add atom.config.observe("foldername-tabs.filenameFirst", @repaint)
    log "loaded"
  repaint: =>
    if @processed
      processAllTabs(true)
      processAllTabs()
  toggle: =>
    @processed = processAllTabs(@processed)
  destroy: =>
    @processed = processAllTabs(true)
    @disposables?.dispose()
    @disposables = null
