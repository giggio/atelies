require("mocha-as-promised")()
chai = require 'chai'
chai.should()
chai.use require 'chai-fuzzy'
global.sinon = require 'sinon'
chai.Assertion.includeStack = true
global.expect = chai.expect
chai.use require "sinon-chai"
chai.use require 'chai-datetime'
chai.use require "chai-as-promised"
