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
    #platform: 'Windows 2012 R2'
  - name: ie
    version: [latest]
    #platform: 'Windows 2012'
  - name: firefox
    version: 25..latest
    #platform: 'Linux'
  - name: safari
    version: [5..latest]
  - name: iphone
    version: [7.1,latest]
  - name: ipad
    version: oldest
  - name: android
    version: ..latest
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
$ karma-sauce
# $ karma start --browsers Sauce --reporters sauce --single-run
# INFO [karma]: Karma v0.12.36 server started at http://localhost:9876/
# INFO [launcher]: Starting browser SauceLauncher
# INFO [wd]: Start Google Chrome@26 at Windows 2012 R2
# INFO [wd]: Start Google Chrome@dev at Windows 2012 R2
# INFO [wd]: Start Google Chrome@beta at Windows 2012 R2
# INFO [wd]: Queuing Internet Explorer@11 at Windows 2012 R2
# INFO [wd]: Queuing Firefox@25 at Linux
# INFO [wd]: Queuing Firefox@26 at Linux
# INFO [wd]: Queuing Firefox@27 at Linux
# INFO [wd]: Queuing Firefox@28 at Linux
# INFO [wd]: Queuing Firefox@29 at Linux
# INFO [wd]: Queuing Firefox@30 at Linux
# INFO [wd]: Queuing Firefox@31 at Linux
# INFO [wd]: Queuing Firefox@32 at Linux
# INFO [wd]: Queuing Firefox@33 at Linux
# INFO [wd]: Queuing Firefox@34 at Linux
# INFO [wd]: Queuing Firefox@35 at Linux
# INFO [wd]: Queuing Firefox@36 at Linux
# INFO [wd]: Queuing Firefox@37 at Linux
# INFO [wd]: Queuing Firefox@38 at Linux
# INFO [wd]: Queuing Safari@5 at Mac 10.6
# INFO [wd]: Queuing Safari@6 at Mac 10.8
# INFO [wd]: Queuing Safari@7 at Mac 10.9
# INFO [wd]: Queuing Safari@8 at Mac 10.10
# INFO [wd]: Queuing iPhone@7.1 at Mac 10.9
# INFO [wd]: Queuing iPhone@8.2 at Mac 10.10
# INFO [wd]: Queuing iPad@4.3 at Mac 10.6
# INFO [wd]: Queuing Android@4.0 at Linux
# INFO [wd]: Queuing Android@4.1 at Linux
# INFO [wd]: Queuing Android@4.2 at Linux
# INFO [wd]: Queuing Android@4.3 at Linux
# INFO [wd]: Queuing Android@4.4 at Linux
# INFO [wd]: Queuing Android@5.0 at Linux
# INFO [wd]: Queuing Android@5.1 at Linux
# INFO [Chrome 26.0.1410 (Windows 8 0.0.0)]: Connected on socket cvxtGM1CwUEe3q2V_jpu with id 0
# INFO [wd]: Passed Google Chrome@26 at Windows 2012 R2 (passed 1/ total 1)
# INFO [wd]: Progress 4/32 Concurrency 3/3 Last false
# INFO [wd]: Start Internet Explorer@11 at Windows 2012 R2
# INFO [Chrome 45.0.2427 (Windows 8.1 0.0.0)]: Connected on socket ScCYxlLQ1MJqrqaV_jpv with id 1
# INFO [Chrome 44.0.2403 (Windows 8.1 0.0.0)]: Connected on socket pCl6OauaaArJN0xC_jpw with id 2
# INFO [wd]: Passed Google Chrome@dev at Windows 2012 R2 (passed 1/ total 1)
# INFO [wd]: Passed Google Chrome@beta at Windows 2012 R2 (passed 1/ total 1)
# INFO [wd]: Progress 5/32 Concurrency 3/3 Last false
# INFO [wd]: Start Firefox@25 at Linux
#
# ...
#
# INFO [wd]: 30 passed, 2 failed. Total 32 browsers.
# INFO [wd]: Total 383.292 sec
```

## Related projects
* [soysauce](https://github.com/59naga/soysauce/)

[![Sauce Test Status][sauce-image]][sauce]

# Better cloud-test libraries
* [zuul](https://github.com/defunctzombie/zuul)
* [karma-sauce-launcher](https://github.com/karma-runner/karma-sauce-launcher)

License
---
[MIT][License]

[License]: http://59naga.mit-license.org/

[sauce-image]: http://soysauce.berabou.me/u/59798/karma-saucelabs-launcher.svg?branch=master
[sauce]: https://saucelabs.com/u/59798
[npm-image]:https://img.shields.io/npm/v/karma-saucelabs-launcher.svg?style=flat-square
[npm]: https://npmjs.org/package/karma-saucelabs-launcher
[travis-image]: http://img.shields.io/travis/59naga/karma-saucelabs-launcher.svg?style=flat-square
[travis]: https://travis-ci.org/59naga/karma-saucelabs-launcher
[coveralls-image]: http://img.shields.io/coveralls/59naga/karma-saucelabs-launcher.svg?style=flat-square
[coveralls]: https://coveralls.io/r/59naga/karma-saucelabs-launcher?branch=master
