# Dependencies
requrest= require 'request'

# Public
class Reporter
  # Karma dependency injections
  constructor: (
    baseReporterDecorator

    # lib/browser_collection.js
    capturedBrowsers

    # Share with the Launcher
    emitter
    sessions
  )->
    baseReporterDecorator this
    
    # Disable summary report (doesn't match the launch)
    @TOTAL_SUCCESS = ''
    @TOTAL_FAILED = ''

    @onBrowserStart= (browser)->
      emitter.emit 'sauce:onBrowserStart',browser

      # Disable browser behaviors
      # Fixed "this._browsers.push is undefined"
      browser.reconnect= ->
      browser.onDisconnect= ->
      capturedBrowsers.remove browser

    # Share to sessions of SauceLauncher's DI
    @onBrowserComplete= (browser)->
      session= sessions[browser.id]
      session.lastResult= browser.lastResult

      emitter.emit 'sauce:onBrowserComplete',browser.id

    @specFailure= (browser,result)->
      session= sessions[browser.id]
      # session.lastResult= browser.lastResult
      
      log= session.driver.log
      log.error '\nFailure: %s %s\n%s',
        result.suite.join(' '),result.description,
        result.log

    @onBrowserError= (browser,error)->
      session= sessions[browser.id]
      session.lastResult= browser.lastResult

      log= session.driver.log

      url= error.match(/http:.+/)?[0] ? ''
      [schemas...,line]= url.split ':'
      uri= schemas.join ':'
      unless line>=0
        log.error '\n%s',error
        emitter.emit 'sauce:onBrowserError',browser.id
        return

      # Extra log report

      url= error.match(/http:.+/)?[0] ? ''
      [schemas...,line]= url.split ':'
      uri= schemas.join ':'

      requrest uri,(ignoredError,response)->
        codeChunk= response?.body?.split('\n')[line-1]

        if codeChunk
          log.error '\n%s\n%s: %s',error,
            line, codeChunk
        else
          log.error '\n%s',error

        emitter.emit 'sauce:onBrowserError',browser.id

module.exports= Reporter