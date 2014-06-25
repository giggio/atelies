ImageManipulation = require '../../app/helpers/imageManipulation'
path  = require 'path'
im    = require('gm').subClass imageMagick: true
Q     = require 'q'

describe 'Image Manipulation', ->
  fileName500x500 = fileName500x700 = fileName700x500 = fileName700x700 = imageManipulation = newFilePath = fileName = null
  before ->
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
      before -> imageManipulation.resize(fileName700x700, undefined).then (newFP) -> newFilePath = newFP
      it 'did not resize', -> Q.ninvoke(im(newFilePath), "size").should.eventually.be.like width: 700, height: 700
      it 'did not set the new path', -> newFilePath.should.equal fileName700x700
    describe '700x700 to be smaller at 600x600', ->
      before -> imageManipulation.resizeAndCrop(fileName700x700, '600x600').then (newFP) -> newFilePath = newFP
      it 'resized', -> Q.ninvoke(im(newFilePath), "size").should.eventually.be.like width: 600, height: 600
      it 'set the new path', -> newFilePath.should.not.equal fileName500x700
    describe '500x500 to be larger at 600x600', ->
      before -> imageManipulation.resize(fileName500x500, '600x600').then (newFP) -> newFilePath = newFP
      it 'resized', -> Q.ninvoke(im(newFilePath), "size").should.eventually.be.like width: 600, height: 600
      it 'set the new path', -> newFilePath.should.not.equal fileName500x700
  describe 'resizing and cropping', ->
    describe 'without dimensions return the same filename', ->
      before -> imageManipulation.resizeAndCrop(fileName700x700, undefined).then (newFP) -> newFilePath = newFP
      it 'did not resize', -> Q.ninvoke(im(newFilePath), "size").should.eventually.be.like width: 700, height: 700
      it 'did not set the new path', -> newFilePath.should.equal fileName700x700
    describe '700x500 to be smaller at 600x300', ->
      before -> imageManipulation.resizeAndCrop(fileName700x500, '600x300').then (newFP) -> newFilePath = newFP
      it 'resized and cropped', -> Q.ninvoke(im(newFilePath), "size").should.eventually.be.like width: 600, height: 300
      it 'set the new path', -> newFilePath.should.not.equal fileName700x500
    describe '500x700 to be smaller at 300x600', ->
      before -> imageManipulation.resizeAndCrop(fileName500x700, '300x600').then (newFP) -> newFilePath = newFP
      it 'resized and cropped', -> Q.ninvoke(im(newFilePath), "size").should.eventually.be.like width: 300, height: 600
      it 'set the new path', -> newFilePath.should.not.equal fileName700x500
