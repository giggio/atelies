module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'
    client:
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
  grunt.registerTask 'default', ['coffee', 'lint']
