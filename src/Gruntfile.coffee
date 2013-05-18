module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'
    coffee:
      compileSpecsClient:
        options:
          sourceMap: true
        expand: true
        cwd: 'public/javascripts/test'
        src: [ '**/*.spec.coffee' ]
        dest: 'public/javascripts/test'
        ext: '.spec.js'
      compileSpecsServer:
        expand: true
        cwd: 'test'
        src: [ '**/*.spec.coffee' ]
        dest: 'test'
        ext: '.spec.js'
      compileClient:
        options:
          sourceMap: true
        expand: true
        cwd: 'public'
        src: [ '**/*.coffee', '!**/*.spec.coffee' ]
        dest: 'public'
        ext: '.js'
      compileServer:
        expand: true
        cwd: ''
        src: [ '**/*.coffee', '!node_modules/**', '!public/**', '!**/*.spec.coffee', '!Gruntfile.coffee' ]
        dest: ''
        ext: '.js'

    coffeelint:
      app: [ '**/*.coffee', '!public/javascripts/test/**', '!test/**', '!node_modules/**', '!Gruntfile.coffee' ]
      tests: [ 'test/**/*.coffee', 'public/javascripts/test/**/*.coffee' ]
      dev: [ 'Cakefile', 'Gruntfile.coffee' ]
      options:
        max_line_length:
          level: 'ignore'
        coffeescript_error:
          level: 'ignore'
  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.registerTask 'default', ['coffeelint']
