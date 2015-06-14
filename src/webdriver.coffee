# Dependencies
Promise= require 'bluebird'

wd= require 'wd'

path= require 'path'
pkg= require process.cwd()+path.sep+'package'

# Private (Without Karma DI)
class Webdriver
  constructor: (uri,@sessions=[],options={})->
    [@url,qs]= uri.split '?'

    @tunnelIdentifier= options.tunnelIdentifier
    @username= options.username
    @accessKey= options.accessKey

    # @sessions= @sessions[...4]
    @begin= Date.now()    
    @current= 0

    @concurrency= options.concurrency ? 3
    @active= 0

    @passed= 0
    @failed= 0

    @log=
      if options.log
        options.log

      # Set the noop logger
      else
        debug: ->
        info: ->
        error: ->

    @done= Promise.defer()

  queue: (browser)->
    {long_name,short_version,os}= browser
    @log.info 'Queuing %s@%s at %s',long_name,short_version,os

  boot: (id)=>
    @log.debug 'Progress %s/%s Concurrency %s/%s (%s)',@current,@sessions.length,@active,@concurrency,(@current is @sessions.length and @active is 0)

    browser= @sessions[id]
    return @queue browser if @active >= @concurrency
    return @finish() if @current is @sessions.length and @active is 0
    return unless browser?

    @current++
    @active++

    {long_name,short_version,os}= browser
    @log.info 'Start %s@%s at %s',long_name,short_version,os

    uri= @url+'?id='+id # See karma/client/karma.js:13
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

    driver= @launch uri,options
    driver.heartbeat= setInterval =>
      driver.title().then null,(error)=>
        @log.error error if @log
        @complete id
    ,60000

    # Share to sessions of Reporter's DI
    @sessions[id].driver= driver

  launch: (url,options)->
    args= [
      'ondemand.saucelabs.com'
      80
      @username
      @accessKey
    ]

    driver= wd.promiseChainRemote args...
    driver.on 'status',(info)=>
      @log.debug info
    driver.on 'command',(eventType,command,response)=>
      @log.debug eventType,command,(response or '')
    driver.on 'http',(meth,path,data)=>
      @log.debug meth,path,(data or '')

    driver
    .init(options)
    .get(url)

    driver

  complete: (id)->
    session= @sessions[id]

    return @log.error 'Can not complete invalid session' unless session?.driver

    @active--
    {driver,lastResult,long_name,short_version,os}= session

    @log.debug 'Stop heartbeat in %s@%s at %s',long_name, short_version, os, id
    clearInterval driver.heartbeat

    lastResult?= {crash:true}
    pass= not (lastResult.crash or lastResult.failed or lastResult.error)

    if pass
      @passed++
      @log.info 'Passed %s@%s at %s (passed %s/ total %s)', long_name, short_version, os, lastResult.success, lastResult.total
    else
      @failed++
      @log.error 'Failed %s@%s at %s (passed %s/ failed %s/ total %s)', long_name, short_version, os, lastResult.success|0, lastResult.failed|0, lastResult.total|0

    @log.debug 'Shutting down %s@%s at %s',long_name, short_version, os, id

    # https://github.com/defunctzombie/zuul/issues/76
    quitId= setTimeout (-> quitted()),1000
    quitted= =>
      return unless session.driver
      delete session.driver

      @boot @current

    driver
    .get 'about:blank'
    .sauceJobStatus pass
    .quit quitted

  finish: ->
    @log.info '%s passed, %s failed. Total %s browsers.',@passed,@failed,@sessions.length
    @log.info 'Total %s sec',(Date.now()-@begin)/1000

    if @passed is @sessions.length
      @log.debug "Exit code is 0"
      @done.resolve 0
    else
      @log.debug "Exit code is 1"
      @done.resolve 1

module.exports= Webdriver