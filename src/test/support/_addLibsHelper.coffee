chai = require 'chai'
chai.should()
chai.use require 'chai-fuzzy'
global.sinon = require 'sinon'
chai.Assertion.includeStack = true
global.expect = chai.expect
sinonChai = require "sinon-chai"
chai.use sinonChai
