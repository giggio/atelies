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
    tests:
      expand: true
      cwd: 'test'
      src: [ '**/*.coffee' ]
      dest: 'test'
      ext: '.js'
    dev: [ 'Cakefile', 'Gruntfile.coffee' ]
    base:
      files:
        'server.js':'server.coffee'

    coffee:
      base: '<%= base %>'
      client:
        files: ['<%= client %>'], options: {sourceMap: true}
      server: '<%= server %>'
      tests: '<%= tests %>'

    coffeelint:
      base: '<%= base %>'
      client: '<%= client %>'
      server: '<%= server %>'
      tests: '<%= tests %>'
      dev: '<%= dev %>'
      options:
        max_line_length:
          level: 'ignore'
        coffeescript_error:
          level: 'ignore'

    watch:
      compile:
        files: [ 'app/**/*.coffee', 'public/**/*.coffee', 'test/**/*.coffee' ]
        tasks: [ 'compile' ]
        options:
          nospawn: true
      compileAndTest:
        files: [ 'app/**/*.coffee', 'public/**/*.coffee', 'test/**/*.coffee' ]
        tasks: [ 'compileAndTest' ]
        options:
          nospawn: true

    express:
      prod:
        options:
          script: 'server.js'
          node_env: 'production'
          port: process.env.PORT
          background: false

    nodemon:
      dev:
        options:
          file: 'server.js'
          watchedExtensions: ['js']
          watchedFolders: ['app']
          debug: true
          delayTime: 2
          #env:
            #PORT: '8181'
          cwd: __dirname

    concurrent:
      devServer:
        tasks: [ 'watch:compileAndTest', 'nodemon:dev', 'nodeInspector' ]
        options:
          logConcurrentOutput: true

    mochacov:
      options:
        ignoreLeaks: true
      server_unit:
        src: 'test/unit/**/*.js'
        options:
          require: ['test/support/_specHelper.js']
          reporter: 'spec'
          ui: 'bdd'
      server_integration:
        src: 'test/integration/**/*.js'
        options:
          require: ['test/support/_specHelper.js']
          reporter: 'spec'
          ui: 'bdd'
          timeout: 40000
      client:
        src: 'public/javascripts/test/**/*.js'
        options:
          require: ['public/javascripts/test/support/runnerSetup.js']
          reporter: 'spec'
          ui: 'bdd'
      server_unit_coverage:
        src: 'test/unit/**/*.js'
        options:
          require: ['test/support/_specHelper.js']
          reporter: 'html-cov'
          ui: 'bdd'
          coverage: true
          output: 'servercoveragereport.html'
      client_unit_coverage:
        src: 'public/javascripts/test/**/*.js'
        options:
          require: ['public/javascripts/test/support/runnerSetup.js']
          reporter: 'html-cov'
          ui: 'bdd'
          coverage: true
          output: 'clientcoveragereport.html'
      travis_server_unit_coverage:
        src: 'test/unit/**/*.js'
        options:
          require: ['test/support/_specHelper.js']
          ui: 'bdd'
          coveralls:
            serviceName: 'travis-ci'
      travis_client_unit_coverage:
        src: 'public/javascripts/test/**/*.js'
        options:
          require: ['public/javascripts/test/support/runnerSetup.js']
          ui: 'bdd'
          coveralls:
            serviceName: 'travis-ci'

    bower:
      install:
        options:
          target: 'public/javascripts/lib'
          copy: false

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
          preserveLicenseComments: false
          optimizeCss: 'none'
          skipDirOptimize: true
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
                'backboneValidation'
                'epoxy'
                'caroufredsel'
                'imagesloaded'
                'jqform'
                'jqexpander'
                'backboneConfig'
                'converters'
                'jqueryValidationExt'
                'loginPopover'
                'openModel'
                'openRouter'
                'openRoutes'
                'openView'
                'viewsManager'
              ]
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

    shell:
      nodeInspector:
        command: 'node-inspector'
        options:
          stdout: true

  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-express-server'
  grunt.loadNpmTasks 'grunt-mocha-cov'
  grunt.loadNpmTasks 'grunt-bower-task'
  grunt.loadNpmTasks 'grunt-notify'
  grunt.loadNpmTasks 'grunt-contrib-requirejs'
  grunt.loadNpmTasks 'grunt-nodemon'
  grunt.loadNpmTasks 'grunt-concurrent'
  grunt.loadNpmTasks 'grunt-shell'

  _ = grunt.util._
  filterFiles = (files, dir) ->
    _.chain(files)
     .filter((f) -> _(f).startsWith dir)
     .map((f)->_(f).strRight "#{dir}/")
     .value()

  changedFiles = {}
  onChange = grunt.util._.debounce ->
    files = Object.keys(changedFiles)
    serverFiles = filterFiles files, 'app'
    clientFiles = filterFiles files, 'public'
    testFiles = filterFiles files, 'test'
    grunt.config ['server', 'src'], serverFiles
    grunt.config ['client', 'src'], clientFiles
    grunt.config ['tests', 'src'], testFiles
    grunt.config ['dev'], []
    changedFiles = {}
  , 200
  grunt.event.on 'watch', (action, filepath) ->
    changedFiles[filepath] = action
    onChange()

  #TASKS:
  grunt.registerTask 'lint', [ 'coffeelint' ]
  grunt.registerTask 'server', [ 'express:prod' ]
  grunt.registerTask 'nodeInspector', [ 'shell:nodeInspector' ]
  #grunt.registerTask 'nodeInspector', ->
    #grunt.util.spawn
      #cmd: 'node-inspector'
  grunt.registerTask 'compileAndTest', (env) ->
    tasks = [ 'compile' ]
    if grunt.config(['client', 'src']).length isnt 0
      tasks.push 'test:client'
      grunt.log.writeln "Running #{'client'.blue} unit tests"
    if grunt.config(['server', 'src']).length isnt 0 or grunt.config(['tests', 'src']).length isnt 0
      tasks.push 'test:unit'
      grunt.log.writeln "Running #{'server'.blue} unit tests"
    grunt.task.run tasks
  grunt.registerTask 'test', [ 'compile', 'test:nocompile' ]
  grunt.registerTask 'test:travis', [ 'mochacov:travis_server_unit_coverage', 'mochacov:travis_client_unit_coverage' ]
  grunt.registerTask 'test:smoke', [ 'compile', 'test:nocompile:smoke' ]
  grunt.registerTask 'test:nocompile', [ 'test:unit', 'test:client', 'test:integration' ]
  grunt.registerTask 'test:nocompile:smoke', [ 'test:unit', 'test:client' ]
  grunt.registerTask 'test:unit', ['mochacov:server_unit']
  grunt.registerTask 'test:integration', ['mochacov:server_integration']
  grunt.registerTask 'test:client', ['mochacov:client']
  grunt.registerTask 'compile', [ 'coffee', 'lint' ]
  grunt.registerTask 'travis', [ 'test:smoke', 'test:travis' ]
  grunt.registerTask 'install', [ 'bower', 'compile', 'requirejs:multipackage' ]
  grunt.registerTask 'default', [ 'compileAndTest', 'concurrent:devServer']
