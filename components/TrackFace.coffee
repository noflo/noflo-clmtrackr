# @runtime noflo-browser

noflo = require 'noflo'
clm = require '../libs/clmtrackr.js'
pModel = require '../libs/model_pca_20_svm.js'

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'meh-o'
  c.description = 'track features in face'

  tracker = null
  raf = null
  trackFaceLoop = () ->
    raf = requestAnimationFrame trackFaceLoop
    if tracker
      points = tracker.getCurrentPosition()
      if points
        # Convert to noflo-canvas compatible array
        points = points.map (point) ->
          return {
            type: 'point'
            x: point[0]
            y: point[1]
          }
        c.outPorts.points.send points
        lastPoints = points

  c.inPorts.add 'image',
    datatype: 'object'
    description: 'img, video, or canvas element'
    process: (event, payload) ->
      return unless event is 'data'

      imageToTrack = payload
      return unless imageToTrack.tagName?
      # Clmtrackr needs canvas or video
      if imageToTrack.tagName is 'IMG'
        # Convert img to canvas
        canvas = document.createElement('canvas')
        canvas.width = imageToTrack.width
        canvas.height = imageToTrack.height
        canvas.getContext('2d').drawImage(imageToTrack, 0, 0)
        imageToTrack = canvas

      # Should be canvas or video now
      # TODO error
      return unless imageToTrack.tagName is 'CANVAS' or imageToTrack.tagName is 'VIDEO'

      # Reset if needed
      if tracker
        tracker.stop()
        tracker.reset()
        tracker = null
      if raf
        cancelAnimationFrame raf

      # todo: params.stopOnConvergence for still images
      tracker = new clm.tracker()
      tracker.init pModel
      tracker.start imageToTrack
      raf = requestAnimationFrame trackFaceLoop

  # Add output ports
  c.outPorts.add 'points',
    datatype: 'array'

  c.shutdown = () ->
    if tracker
      tracker.stop()
      tracker = null

  # Finally return the component instance
  return c
