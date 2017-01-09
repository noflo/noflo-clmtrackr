noflo = require 'noflo'
unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-clmtrackr'

describe 'TrackFace component', ->
  # Browser-only for now, uses WebGL
  return unless noflo.isBrowser()

  c = null
  in_image = null
  out_points = null
  loader = null
  before ->
    loader = new noflo.ComponentLoader baseDir
  beforeEach (done) ->
    @timeout 4000
    loader.load 'clmtrackr/TrackFace', (err, instance) ->
      return done err if err
      c = instance
      done()

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
        in_image.send img
      img.src = 'franck_02159.jpg'
