chai = require 'chai'
chai.should()
global.sinon = require 'sinon'
chai.Assertion.includeStack = true
global.expect = chai.expect
sinonChai = require "sinon-chai"
chai.use sinonChai
