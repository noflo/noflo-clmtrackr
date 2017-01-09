noflo = require 'noflo'
unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-clmtrackr'

describe 'WireframeFace component', ->
  # Browser-only for now, uses WebGL
  return unless noflo.isBrowser()

  c = null
  in_points = null
  out_paths = null
  points = null
  loader = null

  before ->
    loader = new noflo.ComponentLoader baseDir
  beforeEach (done) ->
    @timeout 4000
    loader.load 'clmtrackr/WireframeFace', (err, instance) ->
      return done err if err
      c = instance
      done()

  describe 'when instantiated', ->
    it 'should have an input port', ->
      chai.expect(c.inPorts.points).to.be.an 'object'
    it 'should have an output port', ->
      chai.expect(c.outPorts.paths).to.be.an 'object'

  describe 'when given points', ->
    beforeEach ->
      in_points = noflo.internalSocket.createSocket()
      out_paths = noflo.internalSocket.createSocket()
      c.inPorts.points.attach in_points
      c.outPorts.paths.attach out_paths
      # Make points fixture
      points = []
      for i in [0..70]
        points.push
          type: 'point'
          x: Math.random() * 100
          y: Math.random() * 100

    it 'should make the wireframe', (done) ->
      out_paths.once 'data', (data) ->
        chai.expect(data).to.be.an 'array'
        chai.expect(data.length).to.equal 117
        chai.expect(data[0].items[0]).to.equal points[28]
        chai.expect(data[0].items[1]).to.equal points[70]
        chai.expect(data[0].items[2]).to.equal points[13]
        done()

      # Send in points fixture
      in_points.send points
