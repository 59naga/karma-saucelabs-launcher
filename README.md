# Karma-saucelabs-launcher [![NPM version][npm-image]][npm] [![Build Status][travis-image]][travis]

> Launch any browser on SauceLabs at concurrency.

## Installation
```bash
$ npm install karma karma-mocha mocha --save
$ npm install karma-saucelabs-launcher --save
```

# Usage

Create `./.saucelabs.yml` like a below:

```yaml
browsers:
  - name: chrome
    version: oldest,dev,beta
  - name: ie
    version: [oldest]
  - name: firefox
    version: 25..latest
  - name: safari
    version: 5..latest
  - name: iphone
    version: [7.1,latest]
  - name: ipad
    version: oldest
  - name: android
    version: ..latest
```

Change or Create the `./karma.conf.js`

```js
module.exports= function(config) {
  config.set({
    browsers: ['Sauce'],
    reporters: ['sauce'],
    autoWatch: false,
    singleRun: true,
    // Doesn't work if change the above.

    logLevel: 'INFO',

    basePath: '',
    frameworks: ['mocha'],
    files: [
      "test/**/*.js"
    ],
    exclude: [
    ],
    preprocessors: {
    },
    browserify: {
    },
    port: 9876,
    colors: true,
  })
}
```

Create a `./test/index.js`

```js
describe('this',function(){
  it('is',function(){
    // throw new Error('fake')
  })
})
```

Export a environment of SauceLabs

```bash
export SAUCE_USERNAME=*****
export SAUCE_ACCESS_KEY=********-****-****-****-************
```

Start the karma.

```bash
$ karma start
# INFO [karma]: Karma v0.12.36 server started at http://localhost:9876/
# INFO [launcher]: Starting browser SauceLauncher
# WARN [launcher:sauce]: internet explorer@6 is unsupported
# INFO [webdriver]: Start Google Chrome@26 at Windows 2003
# INFO [webdriver]: Start Google Chrome@dev at Windows 2012 R2
# INFO [webdriver]: Start Google Chrome@beta at Windows 2012
# INFO [webdriver]: Queuing Firefox@25 at Mac 10.6
# INFO [webdriver]: Queuing Firefox@26 at Mac 10.6
# INFO [webdriver]: Queuing Firefox@27 at Mac 10.6
# INFO [webdriver]: Queuing Firefox@28 at Mac 10.6
# INFO [webdriver]: Queuing Firefox@29 at Mac 10.6
# INFO [webdriver]: Queuing Firefox@30 at Mac 10.6
# INFO [webdriver]: Queuing Firefox@31 at Mac 10.6
# INFO [webdriver]: Queuing Firefox@32 at Mac 10.6
# INFO [webdriver]: Queuing Firefox@33 at Mac 10.6
# INFO [webdriver]: Queuing Firefox@34 at Mac 10.6
# INFO [webdriver]: Queuing Firefox@35 at Mac 10.6
# INFO [webdriver]: Queuing Firefox@36 at Mac 10.6
# INFO [webdriver]: Queuing Firefox@37 at Mac 10.6
# INFO [webdriver]: Queuing Firefox@38 at Mac 10.6
# INFO [webdriver]: Queuing Safari@5 at Mac 10.6
# INFO [webdriver]: Queuing Safari@6 at Mac 10.8
# INFO [webdriver]: Queuing Safari@7 at Mac 10.9
# INFO [webdriver]: Queuing Safari@8 at Mac 10.10
# INFO [webdriver]: Queuing iPhone@7.1 at Mac 10.9
# INFO [webdriver]: Queuing iPhone@8.2 at Mac 10.10
# INFO [webdriver]: Queuing iPad@4.3 at Mac 10.6
# INFO [webdriver]: Queuing Android@4.0 at Linux
# INFO [webdriver]: Queuing Android@4.1 at Linux
# INFO [webdriver]: Queuing Android@4.2 at Linux
# INFO [webdriver]: Queuing Android@4.3 at Linux
# INFO [webdriver]: Queuing Android@4.4 at Linux
# INFO [webdriver]: Queuing Android@5.0 at Linux
# INFO [webdriver]: Queuing Android@5.1 at Linux
# INFO [webdriver]: Passed Google Chrome@26 at Windows 2003 (passed 1/ total 1)
# INFO [webdriver]: Start Firefox@25 at Mac 10.6
# INFO [Chrome 44.0.2403 (Windows 8 0.0.0)]: Connected on socket tGbzEr3BxXZF3sYEOnk7 with id 2
# INFO [Chrome 45.0.2427 (Windows 8.1 0.0.0)]: Connected on socket GSCwR4zNGWuCfQGgOnk8 with id 1
# INFO [webdriver]: Passed Google Chrome@beta at Windows 2012 (passed 1/ total 1)
# INFO [webdriver]: Passed Google Chrome@dev at Windows 2012 R2 (passed 1/ total 1)
# INFO [webdriver]: Start Firefox@26 at Mac 10.6
# INFO [webdriver]: Start Firefox@27 at Mac 10.6
# ...
# INFO [webdriver]: 21 passed, 10 failed. Total 31 browsers.
# INFO [webdriver]: Total 282.38 sec
```

# Better cloud-test libraries
* [zuul](https://github.com/defunctzombie/zuul)
* [karma-sauce-launcher](https://github.com/karma-runner/karma-sauce-launcher)

License
---
[MIT][License]

[License]: http://59naga.mit-license.org/

[npm-image]:https://img.shields.io/npm/v/karma-saucelabs-launcher.svg?style=flat-square
[npm]: https://npmjs.org/package/karma-saucelabs-launcher
[travis-image]: http://img.shields.io/travis/59naga/karma-saucelabs-launcher.svg?style=flat-square
[travis]: https://travis-ci.org/59naga/karma-saucelabs-launcher
[coveralls-image]: http://img.shields.io/coveralls/59naga/karma-saucelabs-launcher.svg?style=flat-square
[coveralls]: https://coveralls.io/r/59naga/karma-saucelabs-launcher?branch=master
