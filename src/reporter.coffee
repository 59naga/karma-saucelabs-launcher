class Reporter
  # Karma dependency injections
  constructor: (
    baseReporterDecorator
    capturedBrowsers # lib/browser_collection.js

    emitter
    logger

    sessions # ./index
  )->
    baseReporterDecorator this

    log= logger.create 'reporter:sauce'
    @onBrowserStart= (browser)=>
      log.debug 'sauce:onBrowserStart',JSON.stringify browser
      emitter.emit 'sauce:onBrowserStart',browser

      # Disable browser behaviors
      # Fixed "this._browsers.push is undefined"
      browser.reconnect= ->
      browser.onDisconnect= ->

    # Share to sessions of SauceLauncher's DI
    @onBrowserComplete= (browser)=>
      log.debug 'sauce:onBrowserComplete',JSON.stringify browser

      sessions[browser.id].lastResult= browser.lastResult

      emitter.emit 'sauce:onBrowserComplete',browser.id
      capturedBrowsers.remove browser

    @onBrowserError= (browser,error)=>
      log.debug 'sauce:onBrowserError',JSON.stringify browser

      sessions[browser.id].lastResult= browser.lastResult

      emitter.emit 'sauce:onBrowserError',browser.id
      capturedBrowsers.remove browser

module.exports= Reporter