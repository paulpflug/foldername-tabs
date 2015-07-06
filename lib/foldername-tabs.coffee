sep = require("path").sep
log = require("atom-simple-logger")(pkg:"foldername-tabs",nsp:"core")



{CompositeDisposable} = require 'atom'
paths = {}

makeShortcut = (path) ->
  foldername = path.split('/')[path.split('/').length - 1]
  if foldername.indexOf('-') == -1
    return foldername.replace(/[aeyuio]/g, '').slice(0,3)
  else
    return foldername.split('-').map((w)-> return w[0]).join('-')

# Parses a string path into an object containing the shortened foldername
# and filename
parsePath = (path) ->
  result = {}
  relativePath = atom.project.relativizePath path
  if relativePath?[0]? # within a project folder
    splitted = relativePath[1].split(sep)
    result.filename = splitted.pop()
    projectPaths = atom.project.getPaths()
    pathIdentifier = ""
    if projectPaths.length > 1 # multi-folder project
      useNums = false
      if useNums
        pathIdentifier += "#{projectPaths.indexOf(relativePath[0])+1}"
      else
        pathIdentifier += makeShortcut relativePath[0]
      pathIdentifier += sep if splitted.length > 0
    last = ""
    if splitted.length > 0
      last = splitted.pop()
    if splitted.length > 0
      if splitted.length > 2
        splitted = splitted.splice(2)
      result.foldername = pathIdentifier+
        splitted.map(-> return "...").join(sep)+sep+last
    else # in root folder of project
      result.foldername = pathIdentifier+last
  else # outside of project
    splitted = path.split(sep)
    result.filename = splitted.pop()
    result.foldername = "#{sep}...#{sep}"+splitted.pop()+sep
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
      div.title[data-path='#{path.replace(/\\/g,"\\\\")}']"
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
        if paths[path].foldername != ""
          foldernameElement = document.createElement("span")
          foldernameElement.classList.add "folder"
          foldernameElement.innerHTML = paths[path].foldername
          container.appendChild foldernameElement
        filenameElement = document.createElement("span")
        filenameElement.classList.add "file"
        if paths[path].foldername == ""
          filenameElement.classList.add "file-only"
        filenameElement.innerHTML = paths[path].filename
        container.appendChild filenameElement
        tab.appendChild container
  return !revert
module.exports =
class FoldernameTabs
  disposables: null
  processed: false
  constructor:  ->
    @processed = processAllTabs()
    unless @disposables?
      @disposables = new CompositeDisposable
      @disposables.add atom.workspace.onDidAddTextEditor ->
        setTimeout processAllTabs, 10
      @disposables.add atom.workspace.onDidDestroyPaneItem ->
        setTimeout processAllTabs, 10
      @disposables.add atom.commands.add 'atom-workspace',
      'foldername-tabs:toggle': @toggle
    log "loaded"
  toggle: =>
    @processed = processAllTabs(@processed)
  destroy: =>
    @processed = processAllTabs(true)
    @disposables?.dispose()
    @disposables = null
