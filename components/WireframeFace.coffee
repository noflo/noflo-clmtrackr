# @runtime noflo-browser

noflo = require 'noflo'

# Voronoi version, could be hand-made
# Indexes correspond to https://github.com/auduno/clmtrackr#clmtrackr 
wireframe = [[28,70,13],[39,12,13],[70,39,13],[14,28,13],[50,11,12],[39,50,12],[15,28,14],[50,10,11],[31,39,70],[67,28,15],[16,67,15],[51, 9,10],[50,51,10],[39,38,50],[38,49,50],[40,39,31],[29,67,16],[67,70,28],[51,52,9],[17,29,16],[69,40,31],[32,70,67],[52, 8, 9],[32,31,70],[29,32,67],[68,32,29],[17,68,29],[32,69,31],[68,69,32],[52,53, 8],[53, 7, 8],[30,40,69],[18,68,17],[49,59,50],[58,51,50],[59,58,50],[41,40,30],[68,30,69],[38,48,49],[18,30,68],[58,52,51],[43,38,39],[40,43,39],[37,48,38],[18,33,30],[33,41,30],[48,59,49],[57,52,58],[62,43,40],[43,37,38],[53,6,7],[59,60,58],[60,57,58],[41,62,40],[48,60,59],[22,33,18],[57,53,52],[54,6,53],[62,37,43],[37,47,48],[47,60,48],[33,25,41],[41,34,62],[62,42,37],[37,46,47],[57,54,53],[47,46,60],[61,56,60],[60,56,57],[56,54,57],[36,46,37],[46,61,60],[34,42,62],[42,36,37],[25,34,41],[5,6,54],[22,25,33],[25,65,34],[55,5,54],[45,61,46],[36,45,46],[64,25,22],[34,35,42],[56,55,54],[35,36,42],[45,44,61],[61,44,56],[44,55,56],[44,45,36],[35,44,36],[26,35,34],[65,26,34],[4,5,55],[21,64,22],[26,66,35],[2,44,35],[44,4,55],[2,3,44],[66,1,35],[64,65,25],[21,24,64],[1,2,35],[27,65,64],[3,4,44],[24,27,64],[27,26,65],[20,24,21],[23,1,66],[20,63,24],[24,63,27],[66,26,27],[63,66,27],[20,19,63],[19,23,63],[63,23,66],[0,1,23],[19,0,23]]

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'meh-o'
  c.description = 'Points from TrackFace to wireframe (array of triangle paths)'

  c.inPorts.add 'points',
    datatype: 'array'
    description: 'points from TrackFace'
    process: (event, payload) ->
      return unless event is 'data'
      paths = []
      for tri in wireframe
        console.log tri
        path =
          type: 'path'
          items: [
            payload[tri[0]]
            payload[tri[1]]
            payload[tri[2]]
          ]
        paths.push path

      c.outPorts.paths.send paths

  c.outPorts.add 'paths',
    datatype: 'array'

  # Finally return the component instance
  return c
