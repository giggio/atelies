ImageManipulation = require '../../app/helpers/imageManipulation'
path = require 'path'
im = require('gm').subClass imageMagick: true

describe 'Account order detail page', ->
  fileName500x500 = fileName500x700 = fileName700x500 = fileName700x700 = imageManipulation = newFilePath = fileName = null
  before =>
    imageManipulation = new ImageManipulation()
    fileName500x500 = path.join __dirname, 'support', 'images', '500x500.png'
    fileName500x700 = path.join __dirname, 'support', 'images', '500x700.png'
    fileName700x500 = path.join __dirname, 'support', 'images', '700x500.png'
    fileName700x700 = path.join __dirname, 'support', 'images', '700x700.png'
  describe 'random name', ->
    it 'gives a random name with correct extension', ->
      tempRandomName = imageManipulation._tempRandomName fileName500x500
      path.extname(tempRandomName).should.equal '.png'
  describe 'resizing', ->
    describe 'without dimensions return the same filename', ->
      before (done) ->
        imageManipulation.resize fileName700x700, undefined, (err, newFP) ->
          newFilePath = newFP
          done()
      it 'did not resize', (done) ->
        im(newFilePath).size (err, size) ->
          size.should.be.like width: 700, height: 700
          done()
      it 'did not set the new path', ->
        newFilePath.should.equal fileName700x700
    describe '700x700 to be smaller at 600x600', ->
      before (done) ->
        imageManipulation.resize fileName700x700, '600x600', (err, newFP) ->
          newFilePath = newFP
          done()
      it 'resized', (done) ->
        im(newFilePath).size (err, size) ->
          size.should.be.like width: 600, height: 600
          done()
      it 'set the new path', ->
        newFilePath.should.not.equal fileName500x700
    describe '500x500 to be larger at 600x600', ->
      before (done) ->
        imageManipulation.resize fileName500x500, '600x600', (err, newFP) ->
          newFilePath = newFP
          done()
      it 'resized', (done) ->
        im(newFilePath).size (err, size) ->
          size.should.be.like width: 600, height: 600
          done()
      it 'set the new path', ->
        newFilePath.should.not.equal fileName500x700
  describe 'resizing and cropping', ->
    describe 'without dimensions return the same filename', ->
      before (done) ->
        imageManipulation.resizeAndCrop fileName700x700, undefined, (err, newFP) ->
          newFilePath = newFP
          done()
      it 'did not resize', (done) ->
        im(newFilePath).size (err, size) ->
          size.should.be.like width: 700, height: 700
          done()
      it 'did not set the new path', ->
        newFilePath.should.equal fileName700x700
    describe '700x500 to be smaller at 600x300', ->
      before (done) ->
        imageManipulation.resizeAndCrop fileName700x500, '600x300', (err, newFP) ->
          newFilePath = newFP
          done()
      it 'resized and cropped', (done) ->
        im(newFilePath).size (err, size) ->
          size.should.be.like width: 600, height: 300
          done()
      it 'set the new path', ->
        newFilePath.should.not.equal fileName700x500
    describe '500x700 to be smaller at 300x600', ->
      before (done) ->
        imageManipulation.resizeAndCrop fileName500x700, '300x600', (err, newFP) ->
          newFilePath = newFP
          done()
      it 'resized and cropped', (done) ->
        im(newFilePath).size (err, size) ->
          size.should.be.like width: 300, height: 600
          done()
      it 'set the new path', ->
        newFilePath.should.not.equal fileName700x500
