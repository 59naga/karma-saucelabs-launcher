# Dependencies
spawn= (require 'child_process').spawn
path= require 'path'

# Specs
describe 'Launcher',->
  it '01.All pass launched 5 browsers',(done)->
    options=
      stdio: 'inherit'
      cwd: __dirname+path.sep+'01'

    child= spawn 'node',['../../karma-sauce'],options
    child.once 'close',(code)->
      expect(code).toBe 0
      done()