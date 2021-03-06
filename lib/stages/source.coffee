{BaseStage} = require('./base')
stages = require('../stages')
nodes = require('sql-parser').nodes


# Source
# ---------
# A source abstracts away the difference between a
# raw source stream and a source that is a sub-select
exports.Source = class Source extends BaseStage
  constructor: (@context, subSelect) ->
    if subSelect.constructor is nodes.SubSelect
      @query = subSelect.select
      @alias = subSelect.name
      @select = new stages.Select(@context, @query)
      @select.on 'insert', (newValues) => @emit('insert', @alised(newValues))
      @select.on 'remove', (oldValues) => @emit('remove', @alised(oldValues))
    else
      @alias = subSelect.name.value
      @listener = new stages.Listen(@context, @alias)
      @listener.on 'data', (data) => @emit('insert', data)
  
  stop: ->
    return @select.destroy() if @select
    @listener.stop()
    
  insert: (data) ->
    @select.insert(data)

  remove: (data) ->
    @select.remove(data)

  insertRemove: (i,r) ->
    @select.insertRemove(i,r)

  alised: (data) ->
    return data unless @alias
    obj = {}
    obj[@alias.value] = data
    obj
  
  isWindowed: -> @select and @select.isWindowed()