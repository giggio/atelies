_           = require 'underscore'
_.str = require 'underscore.string'
_.mixin _.str.exports()
module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'
    client:
      expand: true
      cwd: 'public'
      src: [ '**/*.coffee', '!javascripts/lib/**/*' ]
      dest: 'public'
      ext: '.js'
    server:
      expand: true
      cwd: 'app'
      src: [ '**/*.coffee' ]
      dest: 'app'
      ext: '.js'
    test:
      expand: true
      cwd: 'test'
      src: [ '**/*.coffee' ]
      dest: 'test'
      ext: '.js'
    dev: [ 'Gruntfile.coffee' ]
    base:
      files:
        'server.js':'server.coffee'

    coffee:
      base: '<%= base %>'
      client: '<%= client %>'
      server: '<%= server %>'
      test: '<%= test %>'

    coffeelint:
      client: '<%= client %>'
      server: '<%= server %>'
      test: '<%= test %>'
      dev: '<%= dev %>'
      options:
        configFile: 'coffeelint.json'

    watch:
      options:
        livereload: true
      coffeeClient:
        files: [ 'public/**/*.coffee' ]
        tasks: [ 'compileLintAndTest:client' ]
        options:
          livereload: false
      coffeeServer:
        files: [ 'app/**/*.coffee', 'test/**/*.coffee' ]
        tasks: [ 'compileLintAndTest:server' ]
        options:
          livereload: false
      less:
        files: [ 'public/**/*.less' ]
        tasks: [ 'less:dev' ]
        options:
          livereload: false
      css:
        files: [ 'public/**/*.css' ]
      html:
        files: [ 'public/**/*.html' ]
      images:
        files: [ 'public/**/*.jpg', 'public/**/*.png', 'public/**/*.gif' ]

    express:
      prod:
        options:
          script: 'server.js'
          node_env: 'production'
          port: process.env.PORT
          background: false

    nodemon:
      dev:
        script: 'server.js'
        options:
          ext: 'js'
          ignore: ['node_modules/**', 'public/**']
          watch: ['app']
          nodeArgs: ['--debug']
          delay: 2000
          env:
            NODE_ENV: 'development'
            PORT: 3000
            UPLOAD_FILES: true
          cwd: __dirname

    concurrent:
      watchAndDevServer:
        tasks: [ 'watch', 'nodemon:dev' ]
        options:
          logConcurrentOutput: true
      completeDefaultStart:
        tasks: [ 'watch', 'nodemon:dev', 'completeDefaultStart' ]
        options:
          logConcurrentOutput: true

    mochaTest:
      server_unit:
        src: 'test/unit/**/*.js'
        options:
          require: 'test/support/_specHelper.js'
          reporter: 'nyan'
          ui: 'bdd'
      server_unit_spec:
        src: 'test/unit/**/*.js'
        options:
          require: 'test/support/_specHelper.js'
          reporter: 'spec'
          ui: 'bdd'
      server_integration:
        src: 'test/integration/**/*.js'
        options:
          require: 'test/support/_specHelper.js'
          reporter: 'spec'
          ui: 'bdd'
          timeout: 20000
      client:
        src: [ 'public/javascripts/test/**/*.js', '!public/javascripts/test/support/_instrumentForCoverage.js' ]
        options:
          require: 'public/javascripts/test/support/runnerSetup.js'
          reporter: 'nyan'
          ui: 'bdd'
      client_spec:
        src: [ 'public/javascripts/test/**/*.js', '!public/javascripts/test/support/_instrumentForCoverage.js' ]
        options:
          require: 'public/javascripts/test/support/runnerSetup.js'
          reporter: 'spec'
          ui: 'bdd'
      server_unit_coverage:
        src: 'test/unit/**/*.js'
        options:
          require: ['test/support/_instrumentForCoverage.js', 'test/support/_specHelper.js']
          ui: 'bdd'
          quiet: on
          reporter: 'html-cov'
          captureFile: 'coverage-serverUnit.html'
      client_unit_coverage:
        src: 'public/javascripts/test/**/*.js'
        options:
          require: [ 'public/javascripts/test/support/_instrumentForCoverage.js', 'public/javascripts/test/support/runnerSetup.js' ]
          reporter: 'html-cov'
          ui: 'bdd'
          quiet: on
          captureFile: 'coverage-client.html'
      server_unit_coverage_lcov:
        src: 'test/unit/**/*.js'
        options:
          require: ['test/support/_instrumentForCoverage.js', 'test/support/_specHelper.js']
          ui: 'bdd'
          reporter: 'mocha-lcov-reporter'
          quiet: on
          captureFile: 'coverage-serverUnit.lcov.info'
      client_unit_coverage_lcov:
        src: 'public/javascripts/test/**/*.js'
        options:
          require: [ 'public/javascripts/test/support/_instrumentForCoverage.js', 'public/javascripts/test/support/runnerSetup.js' ]
          ui: 'bdd'
          reporter: 'mocha-lcov-reporter'
          quiet: on
          captureFile: 'coverage-client.lcov.info'

    coveralls:
      server_unit_coverage:
        src: 'coverage-serverUnit.lcov.info'
      client_unit_coverage:
        src: 'coverage-client.lcov.info'

    bower:
      install:
        options:
          target: 'public/javascripts/lib'
          copy: false
          verbose: true

    requirejs:
      singlefile:#do not use, just an example, the multipackage uses a shared component
        options:
          baseUrl: 'public/javascripts'
          mainConfigFile: 'public/javascripts/bootstrap.js'
          name: 'adminBootstrap'
          include: ['areas/admin/router']
          out: 'public/javascripts/adminBootstrap-built.js'
          generateSourceMaps: true
          optimize: "uglify2"
          preserveLicenseComments: false
      multipackage:
        options:
          appDir: 'public'
          baseUrl: 'javascripts'
          dir: 'compiledPublic'
          mainConfigFile: 'public/javascripts/bootstrap.js'
          generateSourceMaps: true
          optimize: "uglify2"
          #uglify2:
            #output:
              #beautify: true
          preserveLicenseComments: false
          optimizeCss: 'none'
          skipDirOptimize: true
          paths:
            ga: 'empty:'
            gplus: 'empty:'
            facebook: 'empty:'
            twitter: 'empty:'
          modules:[
            {
              name: 'bootstrap'
              include: [
                'jquery'
                'jqval'
                'underscore'
                'backbone'
                'handlebars'
                'text'
                'twitterBootstrap'
                'showdown'
                'md5'
                'swag'
                'select2en'
                'select2'
                'backboneValidation'
                'epoxy'
                'caroufredsel'
                'imagesloaded'
                'jqform'
                'jqexpander'
                'backboneConfig'
                'baseLibs'
                'converters'
                'errorLogger'
                'jqueryValidationExt'
                'logger'
                'loginPopover'
                'openModel'
                'openRouter'
                'openView'
                'viewsManager'
              ]
            }
            {
              name: 'siteAdminBootstrap'
              include: ['areas/siteAdmin/router']
              exclude: ['bootstrap']
            }
            {
              name: 'adminBootstrap'
              include: ['areas/admin/router']
              exclude: ['bootstrap']
            }
            {
              name: 'accountBootstrap'
              include: ['areas/account/router']
              exclude: ['bootstrap']
            }
            {
              name: 'homeBootstrap'
              include: ['areas/home/router']
              exclude: ['bootstrap']
            }
            {
              name: 'loginBootstrap'
              exclude: ['bootstrap']
            }
            {
              name: 'storeBootstrap'
              include: ['areas/store/router']
              exclude: ['bootstrap']
            }
          ]

    less:
      production:
        options:
          yuicompress: true
          report: 'min'
        files:
          "compiledPublic/stylesheets/style.css": "compiledPublic/stylesheets/style.less"
      dev:
        options:
          report: 'min'
        files:
          "public/stylesheets/style.css": "public/stylesheets/style.less"
    wait:
      watch:
        options:
          delay: 1000
          after: ->
            return true unless _.isEmpty changedFiles
            undefined
    copy:
      fonts:
        files: [
          src: ['**'], dest: 'public/fonts/bootstrap/', cwd: 'public/javascripts/lib/bootstrap/fonts/', expand: true
        ]

    shell:
      browserCoverageClient:
        command: 'google-chrome coverage-client.html'
      browserCoverageServer:
        command: 'google-chrome coverage-serverUnit.html'

  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-express-server'
  grunt.loadNpmTasks 'grunt-bower-task'
  grunt.loadNpmTasks 'grunt-contrib-requirejs'
  grunt.loadNpmTasks 'grunt-nodemon'
  grunt.loadNpmTasks 'grunt-concurrent'
  grunt.loadNpmTasks 'grunt-shell'
  grunt.loadNpmTasks 'grunt-contrib-less'
  grunt.loadNpmTasks 'grunt-wait'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-mocha-test'
  grunt.loadNpmTasks 'grunt-coveralls'
  grunt.loadNpmTasks 'grunt-notify'

  #TASKS:
  grunt.registerTask 'server', [ 'express:prod' ]
  grunt.registerTask 'test', [ 'test:server', 'test:client', 'test:integration' ]
  grunt.registerTask 'test:travis', [ 'mochaTest:server_unit_coverage_lcov', 'mochaTest:client_unit_coverage_lcov', 'coveralls:server_unit_coverage', 'coveralls:client_unit_coverage'  ]
  grunt.registerTask 'test:smoke', [ 'test:server', 'test:client' ]
  grunt.registerTask 'test:smoke:spec', [ 'mochaTest:server_unit_spec', 'mochaTest:client_spec' ]
  grunt.registerTask 'test:server', ['mochaTest:server_unit']
  grunt.registerTask 'test:integration', ['mochaTest:server_integration']
  grunt.registerTask 'test:unit', ['test:client', 'test:server']
  grunt.registerTask 'test:client', ['mochaTest:client']
  grunt.registerTask 'test:coverage', ['test:coverage:client', 'test:coverage:server']
  grunt.registerTask 'test:coverage:client', ['mochaTest:client_unit_coverage', 'shell:browserCoverageClient']
  grunt.registerTask 'test:coverage:server', ['mochaTest:server_unit_coverage', 'shell:browserCoverageServer']
  grunt.registerTask 'compile', [ 'coffee' ]
  grunt.registerTask 'compile:server', [ 'coffee:base', 'coffee:server' ]
  grunt.registerTask 'compile:test', [ 'coffee:test' ]
  grunt.registerTask 'compile:client', [ 'coffee:client' ]
  grunt.registerTask 'compileAndLint', [ 'compileAndLint:server', 'compileAndLint:test', 'compileAndLint:client' ]
  grunt.registerTask 'compileAndLint:client', [ 'compile:client', 'coffeelint:client' ]
  grunt.registerTask 'compileAndLint:test', [ 'compile:test', 'coffeelint:test' ]
  grunt.registerTask 'compileAndLint:server', [ 'compile:server', 'coffeelint:server' ]
  grunt.registerTask 'compileLintAndTest:client', [ 'compileAndLint:client', 'test:client' ]
  grunt.registerTask 'compileLintAndTest:server', [ 'compileAndLint:server', 'compileAndLint:test' , 'test:server' ]
  grunt.registerTask 'travis', [ 'compile', 'test:smoke:spec', 'test:travis' ]
  grunt.registerTask 'heroku', ->
    home = process.env.HOME
    if home is "/app" #trying to identify heroku
      grunt.log.writeln "#{'IS'.blue} running in heroku, home is #{home.blue}."
      grunt.task.run [ 'compile:server' ]
    else
      grunt.log.writeln "#{'NOT'.red} running in heroku, home is #{home.blue}."
  grunt.registerTask 'install', [ 'bower', 'compile', 'copy:fonts', 'requirejs:multipackage', 'less:production' ]
  grunt.registerTask 'lintAndTest', [ 'coffeelint', 'test:unit' ]
  grunt.registerTask 'completeDefaultStart', [ 'less:dev', 'coffeelint:server', 'compileAndLint:client', 'compileAndLint:test', 'test:unit' ]
  grunt.registerTask 'default', [ 'compile:server', 'concurrent:completeDefaultStart' ]
  grunt.registerTask 'quickstart', [ 'concurrent:watchAndDevServer']
