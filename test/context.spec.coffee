river = require('../lib/river')

describe "Context", ->  
  it "allows adding queries and gives each incremental IDs", ->
    ctx = river.createContext()
    q1 = ctx.addQuery("SELECT * FROM data1")
    q2 = ctx.addQuery("SELECT * FROM data2")
    q2.id.should.eql(q1.id+1)

  it "allows pushing data into a context", ->
    ctx = river.createContext()
    ret = ctx.push('data', foo: 'bar')
    ret.should.eql(true)

  it "Selects data from the correct stream", ->
    ctx = river.createContext()
    callCount = 0
    ctx.addQuery("SELECT * FROM yes", -> callCount++)
    ret = ctx.push('yes', foo: 'bar')
    ret = ctx.push('no', foo: 'bar')
    ret = ctx.push('yes', foo: 'bar')
    callCount.should.eql(2)