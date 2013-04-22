describe 'jasmine before and after all extensions', ->
  describe 'sync before all', ->
    arr = [0]
    beforeAll -> arr.push 1
    it 'calls beforeAll', -> expect(arr).toEqual [0,1]
    it 'calls beforeAll only once', -> expect(arr).toEqual [0,1]
    describe 'nested before all', ->
      beforeAll -> arr.push 2
      it 'calls nested before alls', -> expect(arr).toEqual [0,1,2]
      it 'calls nested before alls only once', -> expect(arr).toEqual [0,1,2]
  describe 'sync before all with before each', ->
    arr = [0]
    beforeAll -> arr.push 1
    beforeEach -> arr.push 2
    it 'calls beforeAll and beforeEach', -> expect(arr).toEqual [0,1,2]
    it 'calls beforeAll only once and beforeEach twice', -> expect(arr).toEqual [0,1,2,2]
    describe 'nested before all and before each', ->
      beforeAll -> arr.push 3
      beforeEach -> arr.push 4
      it 'calls nested before alls only once and beforeEach', -> expect(arr).toEqual [0,1,2,2,3,2,4]
      it 'calls nested before alls only once and beforeEach twice', -> expect(arr).toEqual [0,1,2,2,3,2,4,2,4]
  describe 'async before all', ->
    arr = [0]
    beforeAll -> arr.push 1
    it 'calls beforeAll', (done) ->
      expect(arr).toEqual [0,1]
      done()
    it 'calls beforeAll only once', (done) ->
      expect(arr).toEqual [0,1]
      done()
    describe 'nested before all', ->
      beforeAll -> arr.push 2
      it 'calls nested before alls', -> expect(arr).toEqual [0,1,2]
      it 'calls nested before alls only once', -> expect(arr).toEqual [0,1,2]
  describe 'async before all with before each', ->
    arr = [0]
    beforeAll (done) ->
      waitSeconds 1, ->
        arr.push 1
        done()
    beforeEach -> arr.push 2
    it 'calls beforeAll and beforeEach', -> expect(arr).toEqual [0,1,2]
    it 'calls beforeAll only once and beforeEach twice', -> expect(arr).toEqual [0,1,2,2]
    describe 'nested before all and before each', ->
      beforeAll (done) ->
        waitSeconds 1, ->
          arr.push 3
          done()
      beforeEach -> arr.push 4
      it 'calls nested before alls only once and beforeEach', -> expect(arr).toEqual [0,1,2,2,3,2,4]
      it 'calls nested before alls only once and beforeEach twice', -> expect(arr).toEqual [0,1,2,2,3,2,4,2,4]
