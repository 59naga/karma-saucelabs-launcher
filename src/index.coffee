# Dependencies
Webdriver= require './webdriver'

Promise= require 'bluebird'

sauceConnect= require 'sauce-connect-launcher'

SauceLabs= require 'saucelabs'
YAML= require 'yamljs'
path= require 'path'
finder= require 'saucelabs-finder'

# Environment
connectOptions=
  username: process.env.SAUCE_USERNAME
  accessKey: process.env.SAUCE_ACCESS_KEY
  tunnelIdentifier: 'launcher:sauce'+Date.now()

# Public Karma DI
class Launcher
  constructor: (
    baseLauncherDecorator
    emitter
    logger

    args
    config

    sessions
  )->
    # Karma dependency injections
    baseLauncherDecorator this

    # Override environment/configs
    emitter.setMaxListeners(0)
    # config.browserNoActivityTimeout= 0

    # Setup launcher
    @name= 'SauceLauncher'
    @_retryLimit= -1
    log= logger.create 'launcher:sauce'

    sauceConnectLauncher= null
    @on 'start',(uri)=>
      new Promise (resolve,reject)->
        options= connectOptions
        options.logger= log.debug.bind log

        sauceConnect options,(error,launcher)=>
          return reject error if error?
          sauceConnectLauncher= launcher

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
          log: logger.create 'webdriver'

        process.nextTick ->
          # Receive result of driver via SauceLauncher < emitter < Reporter
          emitter.on 'sauce:onBrowserComplete',(i)-> webdriver.complete i
          emitter.on 'sauce:onBrowserError',(i)-> webdriver.complete i
          webdriver.boot i for session,i in webdriver.sessions

        webdriver.done.promise

      .then (exitCode)=>
        @exitCode= exitCode
        emitter.emitAsync 'exit'

    # Ignore pending of karma/lib/events.js
    emitter.once 'exit',=>
      process.exit @exitCode unless sauceConnectLauncher
      sauceConnectLauncher.close =>
        process.exit @exitCode

# Publish DI
Reporter= require './reporter'
module.exports=
  'sessions': ['value', []]
  'launcher:Sauce': ['type',Launcher]
  'reporter:sauce': ['type',Reporter]
