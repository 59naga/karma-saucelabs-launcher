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
    @on 'start',(uri)->
      # Add Webdriver sessions (and share to Reporter via DI)
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

          url= 'https://saucelabs.com/rest/v1/info/browsers/webdriver'
          log.info 'Found %s wds in %s',sessions.length,url

          resolve()

      .then ->
        new Promise (resolve,reject)->
          options= connectOptions
          options.logger= log.debug.bind log

          sauceConnect options,(error,connect)->
            return reject error if error?
            sauceConnectLauncher= connect

            resolve null

      # Concurrency sessions
      .then ->
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

      .spread (exitCode,passed,failed,count,msec)->
        log.info '%d passed, %d failed. Total %d browsers(%s sec).',
          passed, failed,
          count, msec/1000

        emitter.emit 'run_complete',[],{exitCode}

    @once 'kill',(done)->
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
      .finally ->
        done()

# Publish DI
Reporter= require './reporter'
module.exports=
  'sessions': ['value', []]
  'launcher:Sauce': ['type',Launcher]
  'reporter:sauce': ['type',Reporter]
