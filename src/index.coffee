# Dependencies
Webdriver= require './webdriver'

Promise= require 'bluebird'

sauceConnect= require 'sauce-connect-launcher'

SauceLabs= require 'saucelabs'
YAML= require 'yamljs'
path= require 'path'
finder= require 'saucelabs-finder'

# Disable "WARN [web-server]: 404: /favicon.ico"
# https://github.com/karma-runner/karma/pull/1453
try
  common= (require 'karma/lib/middleware/common')
  serve404= common.serve404
common.serve404= (response,path)->
  if path is '/favicon.ico'
    response.writeHead 404
    return response.end 'NOT FOUND'

  serve404 arguments...

# Environment
connectOptions=
  username: process.env.SAUCE_USERNAME ? 'SAUCE_USERNAME'
  accessKey: process.env.SAUCE_ACCESS_KEY ? 'SAUCE_ACCESS_KEY'
  tunnelIdentifier: 'launcher:sauce'+Date.now()

# Public Karma DI
class Launcher
  constructor: (
    logger

    baseLauncherDecorator
    config

    # Share with the Reporter
    emitter
    sessions
  )->
    log= logger.create 'launcher:sauce'

    # Karma dependency injections
    baseLauncherDecorator this

    # Override environment/configs
    emitter.setMaxListeners 0
    config.browserNoActivityTimeout= 0

    # Setup launcher
    @name= 'SauceLauncher'
    @_retryLimit= -1
    @error= 'failure'
    exitCode= 1

    sauceConnectLauncher= null
    webdriver= null
    @on 'start',(uri)=>
      new Promise (resolve,reject)->
        options= connectOptions
        options.logger= log.debug.bind log

        sauceConnect options,(error,connect)=>
          return reject error if error?
          sauceConnectLauncher= connect

          resolve null

      # Add Webdriver sessions (and share to Reporter via DI)
      .then ->
        new Promise (resolve,reject)->
          log.debug 'Parse .saucelabs.yml'

          saucelabs= new SauceLabs
          saucelabs.getWebDriverBrowsers (error,browsers)->
            return reject error if error?
            finder.load browsers
            finder.yaml= YAML.load process.cwd()+path.sep+'.saucelabs.yml'

            for type in finder.yaml.browsers
              {name,version,platform}= type

              for version,browser of finder.find name,version,platform
                # Doesn't work socket.io
                if version is 'internet explorer@6'
                  log.warn 'internet explorer@6 is unsupported'
                  continue

                log.debug JSON.stringify browser
                sessions.push browser

            log.debug 'Found %s browsers in %s',sessions.length,'https://saucelabs.com/rest/v1/info/browsers/webdriver'

            resolve()

      # Concurrency sessions
      .then =>
        return Promise.resolve 1 if sessions.length is 0

        webdriver= new Webdriver uri,sessions,
          tunnelIdentifier: connectOptions.tunnelIdentifier
          username: connectOptions.username
          accessKey: connectOptions.accessKey
          logger: logger

        process.nextTick ->
          # Receive result of driver via SauceLauncher < emitter < Reporter
          emitter.on 'sauce:onBrowserComplete',(id)-> webdriver.complete id
          emitter.on 'sauce:onBrowserError',(id)-> webdriver.complete id
          webdriver.boot id for session,id in webdriver.sessions

        webdriver.done.promise

      .spread (code,passed,failed,count,msec)=>
        log.info '%d passed, %d failed. Total %d browsers.',passed,failed,count
        log.info 'Total %s sec',msec/1000

        if code is 0
          this._done()
        else
          this._done('failure')

        emitter.emitAsync 'exit'
        .then ->
          # If the karma/lib/server.js isn't quit
          process.exit code

    # Receive "emitter.emitAsync('exit')" Don't use the ".emit"
    emitter.once 'exit',(done)=>
      log.debug 'Stop SauceLauncher...'

      queues= []

      if sauceConnectLauncher
        queues.push new Promise (resolve)->
          sauceConnectLauncher.close resolve
          sauceConnectLauncher= null
      else
        queues.push Promise.resolve()

      if webdriver?.sessions.length
        for session in webdriver.sessions when session.driver?.passed
          queues.push session.driver.passed false

      Promise.all queues
      .finally =>
        log.debug 'Stopped SauceLauncher'

        # Notify to emitAsync of karma/lib/events.js
        done()

# Publish DI
Reporter= require './reporter'
module.exports=
  'sessions': ['value', []]
  'launcher:Sauce': ['type',Launcher]
  'reporter:sauce': ['type',Reporter]
