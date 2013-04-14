Product   = require '../../models/product'
describe 'Product', ->
  it 'should product the correct url', ->
    product = new Product(name: 'name 1', slug: 'name_1', picture: 'http://lorempixel.com/150/150/cats', price: 11.1, storeName: 'store 1', storeSlug: 'store_1')
    expect(product.url()).toBe "#{product.storeSlug}/#{product.slug}"
