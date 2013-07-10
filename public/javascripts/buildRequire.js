//node ../../node_modules/requirejs/bin/r.js -o buildRequire.js
({
  appDir: '..',
  baseUrl: 'javascripts',
  dir: '../../compiledPublic',
  mainConfigFile: './bootstrap.js',
  generateSourceMaps: true,
  optimize: "uglify2",
  preserveLicenseComments: false,
  optimizeCss: 'none',
  skipDirOptimize: true,
  modules:[
    {
      name: 'bootstrap',
      include: [
        'jquery',
        'jqval',
        'underscore',
        'backbone',
        'handlebars',
        'text',
        'twitterBootstrap',
        'backboneValidation',
        'epoxy',
        'caroufredsel',
        'imagesloaded',
        'backboneConfig',
        'converters',
        'jqueryValidationExt',
        'loginPopover',
        'openModel',
        'openRouter',
        'openRoutes',
        'openView',
        'viewsManager'
      ],
    },
    {
      name: 'adminBootstrap',
      include: ['areas/admin/router'],
      exclude: ['bootstrap']
    },
    {
      name: 'accountBootstrap',
      include: ['areas/account/router'],
      exclude: ['bootstrap']
    },
    {
      name: 'homeBootstrap',
      include: ['areas/home/router'],
      exclude: ['bootstrap']
    },
    {
      name: 'loginBootstrap',
      exclude: ['bootstrap']
    },
    {
      name: 'storeBootstrap',
      include: ['areas/store/router'],
      exclude: ['bootstrap']
    },
  ]
})
