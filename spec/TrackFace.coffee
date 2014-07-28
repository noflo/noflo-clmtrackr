noflo = require 'noflo'
unless noflo.isBrowser()
  chai = require 'chai' unless chai
  TrackFace = require '../components/TrackFace.coffee'
else
  TrackFace = require 'noflo-clmtrackr/components/TrackFace.js'

describe 'TrackFace component', ->
  # Browser-only for now, uses WebGL
  return unless noflo.isBrowser()

  c = null
  in_image = null
  out_points = null
  beforeEach ->
    c = TrackFace.getComponent()

  describe 'when instantiated', ->
    it 'should have an input port', ->
      chai.expect(c.inPorts.image).to.be.an 'object'
    it 'should have an output port', ->
      chai.expect(c.outPorts.points).to.be.an 'object'

  describe 'when given image', ->
    beforeEach ->
      in_image = noflo.internalSocket.createSocket()
      out_points = noflo.internalSocket.createSocket()
      c.inPorts.image.attach in_image
      c.outPorts.points.attach out_points

    it 'should find the face', (done) ->
      @timeout 3000

      out_points.once 'data', (data) ->
        console.log data
        chai.expect(data).to.be.an 'array'
        chai.expect(data.length).to.equal 71
        chai.expect(data[0].x).to.be.a 'number'
        chai.expect(data[0].x).to.be.greaterThan 294
        chai.expect(data[0].x).to.be.lessThan 295
        chai.expect(data[0].y).to.be.a 'number'
        chai.expect(data[0].y).to.be.greaterThan 280
        chai.expect(data[0].y).to.be.lessThan 281
        done()

      # Load img and send it in
      img = document.createElement 'img'
      img.onload = () ->
        img.width = img.naturalWidth
        img.height = img.naturalHeight
        console.log img
        in_image.send img
      img.src = 'franck_02159.jpg'
