module.exports= function(config) {
  config.set({
    browsers: ['Sauce'],
    reporters: ['sauce'],
    autoWatch: false,
    singleRun: true,
    
    logLevel: 'INFO',

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