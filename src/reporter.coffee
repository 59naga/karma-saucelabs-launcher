# No Dependencies

# Public
class Reporter
  # Karma dependency injections
  constructor: (
    baseReporterDecorator
    logger

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

    log= logger.create 'reporter:sauce'
    @onBrowserStart= (browser)->
      emitter.emit 'sauce:onBrowserStart',browser

      # Disable browser behaviors
      # Fixed "this._browsers.push is undefined"
      browser.reconnect= ->
      browser.onDisconnect= ->

    # Share to sessions of SauceLauncher's DI
    @onBrowserComplete= (browser)->
      session= sessions[browser.id]
      session.lastResult= browser.lastResult

      emitter.emit 'sauce:onBrowserComplete',browser.id
      capturedBrowsers.remove browser

    @onBrowserError= (browser,error)->
      session= sessions[browser.id]
      session.lastResult= browser.lastResult

      {api_name,short_version,os}= session
      log.error '%s@%s: %s',api_name,short_version,JSON.stringify error

      emitter.emit 'sauce:onBrowserError',browser.id
      capturedBrowsers.remove browser

module.exports= Reporter