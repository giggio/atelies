AccessDenied    = require '../../../errors/accessDenied'

describe 'AccessDenied', ->
  it 'throws', ->
    accessDenied = new AccessDenied 'some msg'
    expect( -> throw accessDenied).to.throw AccessDenied
