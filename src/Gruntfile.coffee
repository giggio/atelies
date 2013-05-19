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

    coffee:
      client:
        files: ['<%= client %>'], options: {sourceMap: true}
      server: '<%= server %>'
      tests: '<%= tests %>'

    coffeelint:
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
      server:
        files: [ 'app/**/*.coffee', 'public/**/*.coffee', 'test/**/*.coffee' ]
        tasks: [ 'compileAndStartServer' ]
        options:
          nospawn: true
          livereload: true
      coffee:
        files: [ 'app/**/*.coffee', 'public/**/*.coffee', 'test/**/*.coffee' ]
        tasks: [ 'coffee', 'coffeelint' ]
        options:
          nospawn: true

    express:
      dev:
        options:
          script: 'server.js'

    cafemocha:
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

  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-express-server'
  grunt.loadNpmTasks 'grunt-cafe-mocha'

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

  grunt.registerTask 'lint', [ 'coffeelint' ]
  grunt.registerTask 'server', [ 'compileAndStartServer', 'watch:server' ]
  grunt.registerTask 'compileAndStartServer', ->
    tasks = [ 'coffee', 'coffeelint' ]
    if grunt.config(['server', 'src']).length isnt 0
      tasks.push 'express:dev'
      grunt.log.writeln 'Compiling and starting server'
    else
      grunt.log.writeln 'Compiling and NOT starting server'
    grunt.task.run tasks
  grunt.registerTask 'test', ['test:unit', 'test:integration', 'test:client' ]
  grunt.registerTask 'test:fast', ['test:unit', 'test:client' ]
  grunt.registerTask 'test:unit', ['cafemocha:server_unit']
  grunt.registerTask 'test:integration', ['cafemocha:server_integration']
  grunt.registerTask 'test:client', ['cafemocha:client']
  grunt.registerTask 'default', ['server']
