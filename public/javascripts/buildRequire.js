//node ../../node_modules/requirejs/bin/r.js -o buildRequire.js
({
  mainConfigFile: './bootstrap.js',
  name: 'adminBootstrap',
  include: ['areas/admin/router'],
  out: 'adminBootstrap-built.js',
  generateSourceMaps: true,
  optimize: "uglify2",
  preserveLicenseComments: false
})
