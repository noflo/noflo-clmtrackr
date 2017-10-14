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
  ctx = null
  stopTracking = ->
    if tracker
      tracker.stop()
      tracker = null
    if raf
      cancelAnimationFrame raf
      raf = null
    if ctx
      ctx.deactivate()
      ctx = null
  c.tearDown = (callback) ->
    do stopTracking
    do callback
  c.inPorts.add 'image',
    datatype: 'object'
    description: 'img, video, or canvas element'
  c.outPorts.add 'points',
    datatype: 'array'
  c.outPorts.add 'error',
    datatype: 'object'

  c.process (input, output, context) ->
    return unless input.hasData 'image'
    imageToTrack = input.getData 'image'
    return output.done() unless imageToTrack.tagName?
    # Clmtrackr needs canvas or video
    if imageToTrack.tagName is 'IMG'
      # Convert img to canvas
      canvas = document.createElement('canvas')
      canvas.width = imageToTrack.width
      canvas.height = imageToTrack.height
      canvas.getContext('2d').drawImage(imageToTrack, 0, 0)
      imageToTrack = canvas

    # Should be canvas or video now
    unless imageToTrack.tagName is 'CANVAS' or imageToTrack.tagName is 'VIDEO'
      output.done new Error 'Image to track must be a canvas or video element'
      return

    # Reset if needed
    do stopTracking

    # todo: params.stopOnConvergence for still images
    tracker = new clm.tracker()
    tracker.init pModel
    tracker.start imageToTrack
    ctx = context

    trackFaceLoop = ->
      raf = requestAnimationFrame trackFaceLoop
      return unless tracker
      points = tracker.getCurrentPosition()
      return unless points
      # Convert to noflo-canvas compatible array
      points = points.map (point) ->
        return {
          type: 'point'
          x: point[0]
          y: point[1]
        }
      output.send
        points: points

    raf = requestAnimationFrame trackFaceLoop
