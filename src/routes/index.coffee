exports.index = (req, res) ->
  res.render "index", products: [
    { id: 1, productName: 'prod 1', picture: 'http://a.jpg', price: 3.43, storeId: 3 }
    { id: 2, productName: 'prod 2', picture: 'http://b.jpg', price: 7.78, storeId: 4 }
  ]
