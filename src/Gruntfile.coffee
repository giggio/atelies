module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')
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
  grunt.registerTask 'default', ['coffeelint']
