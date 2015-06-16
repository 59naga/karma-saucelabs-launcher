# Dependencies
Promise= require 'bluebird'

wd= require 'wd'

try
  path= require 'path'
  pkg= require process.cwd()+path.sep+'package'
catch
  pkg= {name:'Karma test'}

# Public
class Webdriver
  # Unused Karma DI
  constructor: (uri,@sessions=[],options={})->
    [@url,qs]= uri.split '?'

    @tunnelIdentifier= options.tunnelIdentifier
    @username= options.username ? 'SAUCE_USERNAME'
    @accessKey= options.accessKey ? 'SAUCE_ACCESS_KEY'

    @begin= Date.now()
    @current= 0

    @concurrency= options.concurrency ? 3
    @active= 0

    @passed= 0
    @failed= 0

    @logger= options.logger
    @log= @createLogger 'wd'

    @done= Promise.defer()

  createLogger: (name)->
    if @logger
      @logger.create name
    else
      debug: ->
      info: ->
      warn: ->
      error: ->

  queue: (browser)->
    {api_name,short_version,os}= browser
    @log.info 'Queuing %s@%s at %s',api_name,short_version,os

  boot: (id)=>
    browser= @sessions[id]
    return @queue browser if @active >= @concurrency
    return @finish() if @current is @sessions.length and @active is 0
    return unless browser?

    @current++
    @active++

    {api_name,short_version,os}= browser

    @log.debug 'Progress %s/%s Concurrency %s/%s Last %s',
      @current, @sessions.length,
      @active, @concurrency,
      (@current is @sessions.length and @active is 0)
    @log.info 'Start %s@%s at %s',api_name,short_version,os

    options= {}
    options.browserName= browser.api_name
    options.version= browser.short_version
    options.platform= browser.os
    options.tags= []
    options.name= pkg.name
    options['tunnel-identifier']= @tunnelIdentifier
    options['record-video']= true
    options['record-screenshots']= true
    options['device-orientation']= null
    options['disable-popup-handler']= true
    options['build']= process.env.TRAVIS_BUILD_NUMBER
    options['build']?= process.env.BUILD_NUMBER
    options['build']?= process.env.BUILD_TAG
    options['build']?= process.env.CIRCLE_BUILD_NUM

    # Share to sessions of Reporter's DI
    @sessions[id].driver= @launch id,options

  # wd remote factory
  launch: (id,options)->
    args= [
      'ondemand.saucelabs.com'
      80
      @username
      @accessKey
    ]

    {browserName,version,platform}= options
    log= @createLogger "wd:#{browserName}@#{version}(#{platform})"
    driver= wd.promiseChainRemote args...
    driver.on 'status',(info)->
      log.debug info
    driver.on 'command',(eventType,command,response)->
      log.debug eventType,command,(response or '')
    driver.on 'http',(meth,path,data)->
      log.debug meth,path,(data or '')

    uri= @url+'?id='+id # See karma/client/karma.js:13
    driver
    .init options
    .get uri

    # Private
    heartbeatFail= 0
    heartbeat= setInterval =>
      log.debug 'Heartbeat(%s) in %s@%s at %s',heartbeatFail, browserName, version, platform

      driver.title().then null,(error)=>
        heartbeatFail++

        @complete id if heartbeatFail >= 2
        log.warn 'Heartbeat(%s) %s',heartbeatFail, JSON.stringify error
    ,60000

    # Add public
    driver.clearHeartbeat= ->
      clearInterval heartbeat

      log.debug 'Stop heartbeat in %s@%s at %s',browserName, version, platform

    # https://github.com/defunctzombie/zuul/issues/76
    driver.passed= (pass)=>
      new Promise (resolve)=>
        quitId= setTimeout (-> quitted()),2000
        quitted= =>
          return unless quitId
          quitId= null

          @active--
          @boot @current

          resolve()

        driver
        .sauceJobStatus pass
        .get 'about:blank'
        .quit quitted

    driver

  complete: (id)->
    session= @sessions[id]

    return @log.warn 'Can not complete invalid session(%s)',id unless session?.driver

    {driver,lastResult,api_name,short_version,os}= session
    driver.clearHeartbeat() if driver.clearHeartbeat

    lastResult?= {crash:true}
    pass= not (lastResult.crash or lastResult.failed or lastResult.error)

    if pass
      @passed++
      @log.info 'Passed %s@%s at %s (passed %s/ total %s)',
        api_name, short_version,
        os, lastResult.success,
        lastResult.total
    else
      @failed++
      @log.error 'Failed %s@%s at %s (passed %s/ failed %s/ total %s)',
        api_name, short_version,
        os, lastResult.success|0, lastResult.failed|0,
        lastResult.total|0

    @log.debug 'Shutting down %s@%s at %s',api_name, short_version, os

    driver.passed pass
    delete session.driver

  finish: ->
    code= if @passed is @sessions.length then 0 else 1

    @log.debug 'Exit code is %d',code
    
    @done.resolve [code,@passed,@failed,@sessions.length,Date.now()-@begin]

module.exports= Webdriver