module.exports= function(config) {
  config.set({
    browsers: ['Sauce'],
    reporters: ['sauce'],
    singleRun: true,
    
    logLevel: 'DEBUG',

    autoWatch: false,
    basePath: '',
    frameworks: ['mocha'],
    files: [
      "fixtures/**/*.js"
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