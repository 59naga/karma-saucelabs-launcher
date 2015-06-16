# Karma-saucelabs-launcher [![NPM version][npm-image]][npm] [![Build Status][travis-image]][travis]

> Launch any browser on SauceLabs at concurrency.

## Installation
```bash
$ npm install karma-saucelabs-launcher --global
```

# Usage

Create `./.saucelabs.yml` like a below:

```yaml
browsers:
  - name: chrome
    version: latest
  - name: ie
    version: '8,9,10,11'
  - name: firefox
    version: 25..latest
    platform: 'Linux'
  - name: safari
    version: 5..latest
  - name: iphone
    version: '7.1,latest'
  - name: ipad
    version: oldest
  - name: android
    version: ..latest
```

Create a `./test/index.js` (Case: `karma-mocha`)

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
$ karma-sauce --log-level INFO
# $ karma start --log-level INFO --browsers Sauce --reporters sauce --single-runINFO [karma]: Karma v0.12.36 server started at http://localhost:9876/
# INFO [launcher]: Starting browser SauceLauncher
# INFO [launcher:sauce]: Found 33 wds in https://saucelabs.com/rest/v1/info/browsers/webdriver
# INFO [wd]: Start chrome@43 at Mac 10.6
# INFO [wd]: Start internet explorer@8 at Windows 2003
# INFO [wd]: Start internet explorer@9 at Windows 2008
# INFO [wd]: Queuing internet explorer@10 at Windows 2012
# INFO [wd]: Queuing internet explorer@11 at Windows 2012 R2
# INFO [wd]: Queuing firefox@25 at Linux
# INFO [wd]: Queuing firefox@26 at Linux
# INFO [wd]: Queuing firefox@27 at Linux
# INFO [wd]: Queuing firefox@28 at Linux
# INFO [wd]: Queuing firefox@29 at Linux
# INFO [wd]: Queuing firefox@30 at Linux
# INFO [wd]: Queuing firefox@31 at Linux
# INFO [wd]: Queuing firefox@32 at Linux
# INFO [wd]: Queuing firefox@33 at Linux
# INFO [wd]: Queuing firefox@34 at Linux
# INFO [wd]: Queuing firefox@35 at Linux
# INFO [wd]: Queuing firefox@36 at Linux
# INFO [wd]: Queuing firefox@37 at Linux
# INFO [wd]: Queuing firefox@38 at Linux
# INFO [wd]: Queuing safari@5 at Mac 10.6
# INFO [wd]: Queuing safari@6 at Mac 10.8
# INFO [wd]: Queuing safari@7 at Mac 10.9
# INFO [wd]: Queuing safari@8 at Mac 10.10
# INFO [wd]: Queuing iphone@7.1 at Mac 10.9
# INFO [wd]: Queuing iphone@8.2 at Mac 10.10
# INFO [wd]: Queuing ipad@4.3 at Mac 10.6
# INFO [wd]: Queuing android@4.0 at Linux
# INFO [wd]: Queuing android@4.1 at Linux
# INFO [wd]: Queuing android@4.2 at Linux
# INFO [wd]: Queuing android@4.3 at Linux
# INFO [wd]: Queuing android@4.4 at Linux
# INFO [wd]: Queuing android@5.0 at Linux
# INFO [wd]: Queuing android@5.1 at Linux
#
# ...
#
# INFO [wd]: 31 passed, 2 failed. Total 33 browsers(438.264 sec).
```

## Related projects
* [soysauce](https://github.com/59naga/soysauce/)

[![Sauce Test Status][sauce-image]][sauce]

# Better cloud-test libraries
* [karma-sauce-launcher](https://github.com/karma-runner/karma-sauce-launcher)
* [zuul](https://github.com/defunctzombie/zuul)

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
