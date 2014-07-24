noflo = require 'noflo'
tracker = require '../libs/clmtrackr.js'
pModel = require '../libs/model_pca_20_svm.js'

exports.getComponent = ->
  c = new noflo.Component

  # Define a meaningful icon for component from http://fontawesome.io/icons/
  c.icon = 'meh-o'

  # Provide a description on component usage
  c.description = 'track features in face'

  tracker = null
  animate = () ->
    requestAnimationFrame animate
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
        c.outPorts.out.send points

  c.inPorts.add 'image',
    datatype: 'object'
    description: 'img, video, or canvas element'
    process: (event, payload) ->
      return unless event is 'data'
      # c.outPorts.out.send payload

      console.log 'process', event, payload

      # Reset if needed
      if tracker
        tracker.stop()
        tracker = null

      # todo: params.stopOnConvergence for still images
      tracker = new clm.tracker()
      tracker.init pModel
      tracker.start payload

  # Add output ports
  c.outPorts.add 'points',
    datatype: 'array'

  c.shutdown = () ->
    if tracker
      tracker.stop()
      tracker = null

  # Finally return the component instance
  return c
