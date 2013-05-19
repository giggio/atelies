module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    coffee:
      client:
        options:
          sourceMap: true
        expand: true
        cwd: 'public'
        src: [ '**/*.coffee' ]
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

    coffeelint:
      client: [ 'public/**/*.coffee' ]
      server: [ 'app/**/*.coffee' ]
      tests: [ 'test/**/*.coffee' ]
      dev: [ 'Cakefile', 'Gruntfile.coffee' ]
      options:
        max_line_length:
          level: 'ignore'
        coffeescript_error:
          level: 'ignore'

    watch:
      coffee:
        files: ['app/**/*.coffee', 'public/**/*.coffee', 'test/**/*.coffee']
        tasks: ['coffee', 'coffeelint']
        options:
          nospawn: true

  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'

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
    grunt.config ['coffee', 'server', 'src'], serverFiles
    grunt.config ['coffee', 'client', 'src'], clientFiles
    grunt.config ['coffee', 'tests', 'src'], testFiles
    grunt.config ['coffeelint', 'server'], serverFiles
    grunt.config ['coffeelint', 'client'], clientFiles
    grunt.config ['coffeelint', 'tests'], testFiles
    grunt.config ['coffeelint', 'dev'], []
    changedFiles = {}
  , 200
  grunt.event.on 'watch', (action, filepath) ->
    changedFiles[filepath] = action
    onChange()

  grunt.registerTask 'default', ['coffeelint']
