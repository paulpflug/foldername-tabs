pkg = "foldername-tabs"
describe "FoldernameTabs", ->
  [workspaceElement, activationPromise] = []

  beforeEach ->
    atom.devMode = true
    atom.config.set("#{pkg}.debug",2)
    workspaceElement = atom.views.getView(atom.workspace)
    waitsForPromise ->
      atom.packages.activatePackage("tabs")
      .then ->
        atom.workspace.open('sample.js')
      .then ->
        atom.packages.activatePackage(pkg)

  describe "when the foldername-tabs:toggle event is triggered", ->
    it "removes and adds foldernames in tabs", ->
      runs ->
        expect(workspaceElement.querySelector('.tab-bar')).toExist()
        fntElement = workspaceElement.querySelector('div.foldername-tabs')
        expect(fntElement).toExist()
        expect(fntElement.querySelector("span.folder").innerHTML)
          .toEqual "/"
        expect(fntElement.querySelector("span.file").innerHTML)
          .toEqual "sample.js"
        atom.commands.dispatch workspaceElement, 'foldername-tabs:toggle'
        expect(workspaceElement.querySelector('div.foldername-tabs')).not
          .toExist()
        expect(workspaceElement.querySelector('.tab-bar div.title').innerHTML)
          .toEqual("sample.js")
