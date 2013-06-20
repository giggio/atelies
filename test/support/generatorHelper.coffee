Product   = require '../../app/models/product'
Store     = require '../../app/models/store'
User      = require '../../app/models/user'
Order     = require '../../app/models/order'

exports.generator =
  product:
    a: -> new Product
      name: 'name 1'
      slug: 'name_1'
      picture: 'http://lorempixel.com/300/450/cats'
      price: 11.1
      storeName: 'store 1'
      storeSlug: 'store_1'
      tags: ['abc', 'def']
      description: "Mussum ipsum cacilds, vidis litro abertis. Consetis adipiscings elitis."
      dimensions:
        height: 11
        width: 12
        depth: 17
      weight: 4
      shipping:
        dimensions:
          height: 12
          width: 13
          depth: 18
        weight: 4
      hasInventory: true
      inventory: 30
    b: -> new Product
      name: 'name 2'
      slug: 'name_2'
      picture: 'http://lorempixel.com/150/150/cats'
      price: 22.2
      storeName: 'store 1'
      storeSlug: 'store_1'
      tags: ['ghi', 'jkl']
      description: "Suco de cevadiss, é um leite divinis, qui tem lupuliz, matis, aguis e fermentis."
      dimensions:
        height: 15
        width: 16
        depth: 17
      weight: 8
      shipping:
        dimensions:
          height: 16
          width: 17
          depth: 18
        weight: 9
      hasInventory: true
      inventory: 40
    c: -> new Product
      name: 'name 3'
      slug: 'name_3'
      picture: 'http://lorempixel.com/150/150/cats'
      price: 33.33
      storeName: 'store 2'
      storeSlug: 'store_2'
      tags: ['abc', 'mno']
      description: "Casamentiss faiz malandris se pirulitá, Nam liber tempor cum soluta nobis eleifend."
      dimensions:
        height: 19
        width: 20
        depth: 21
      weight: 5
      shipping:
        dimensions:
          height: 20
          width: 21
          depth: 22
        weight: 6
      hasInventory: false
    d: -> new Product
      name: 'name 4'
      slug: 'name_4'
      picture: 'http://lorempixel.com/150/200/cats'
      price: 42.2
      storeName: 'store 1'
      storeSlug: 'store_1'
      tags: ['mno', 'pqr']
      description: "Other Suco de cevadiss, é um leite divinis, qui tem lupuliz, matis, aguis e fermentis."
      dimensions:
        height: 19
        width: 20
        depth: 21
      weight: 12
      shipping:
        dimensions:
          height: 20
          width: 21
          depth: 22
        weight: 13
      hasInventory: true
      inventory: 130
    d: -> new Product
      name: 'Some Cool Item'
      slug: 'some_cool_item'
      picture: 'http://lorempixel.com/150/200/cats/5'
      price: 42.2
      storeName: 'store 1'
      storeSlug: 'store_1'
      tags: ['abc', 'xyz']
      description: "Muito other suco de cevadiss, é um leite divinis, qui tem lupuliz, matis, aguis e fermentis."
      dimensions:
        height: 290
        width: 200
        depth: 210
      weight: 220
      shipping:
        dimensions:
          height: 291
          width: 201
          depth: 211
        weight: 221
      hasInventory: true
      inventory: 230
  store:
    a: -> new Store
      name: 'Store 1'
      slug: 'store_1'
      email: 'a@a.com'
      description: "Store Mussum ipsum cacilds, vidis litro abertis. Consetis adipiscings elitis. Pra lá , depois divoltis porris."
      homePageDescription: "HP Store Mussum ipsum cacilds, vidis litro abertis. Consetis adipiscings elitis. Pra lá , depois."
      homePageImage: 'http://lorempixel.com/400/400/nightlife/1'
      urlFacebook: 'fbstore1'
      urlTwitter: 'twstore1'
      phoneNumber: '(11) 98745-7894'
      city: "São Paulo"
      state: "SP"
      zip: "01234-567"
      otherUrl: 'http://myotherurl.com'
      banner: 'http://lorempixel.com/800/150/cats/1'
      flyer: 'http://lorempixel.com/350/400/nightlife/1'
    b: -> new Store
      name: 'Store 2'
      slug: 'store_2'
      email: 'b@a.com'
      description: "Store Suco de cevadiss, é um leite divinis, qui tem lupuliz, matis, aguis e fermentis."
      homePageDescription: "HP Store Suco de cevadiss, é um leite divinis, qui tem lupuliz, matis, aguis e fermentis."
      homePageImage: 'http://lorempixel.com/400/400/nightlife/2'
      urlFacebook: 'fbstore2'
      urlTwitter: 'twstore2'
      phoneNumber: '(85) 7788-1111'
      city: "Fortaleza"
      state: "CE"
      zip: "04365-000"
      otherUrl: 'http://someotherurl.com'
      flyer: 'http://lorempixel.com/350/400/nightlife/2'
    c: -> new Store
      name: 'Store 3'
      slug: 'store_3'
      email: 'c@a.com'
      description: "Store Casamentiss faiz malandris se pirulitá."
      homePageDescription: "HP Store Casamentiss faiz malandris se pirulitá."
      homePageImage: 'http://lorempixel.com/400/400/nightlife/3'
      urlFacebook: 'fbstore3'
      urlTwitter: 'twstore3'
      phoneNumber: '(77) 9999-9999'
      city: "Manaus"
      state: "AM"
      zip: "04234-567"
      otherUrl: 'http://idontownthisstore.com'
      flyer: 'http://lorempixel.com/350/400/nightlife/3'
    d: -> new Store
      name: 'My Very Nice Store'
      slug: 'my_very_nice_store'
      phoneNumber: '(77) 9999-9999'
      email: 'd@a.com'
      description: "Store Muito other suco de cevadiss, é um leite divinis, qui tem lupuliz."
      homePageDescription: "HP Store Muito other suco de cevadiss, é um leite divinis, qui tem lupuliz."
      homePageImage: 'http://lorempixel.com/400/400/nightlife/4'
      urlFacebook: ''
      urlTwitter: ''
      city: "Campo Grande"
      state: "MS"
      zip: "04334-567"
      otherUrl: 'http://somestoreinms.com'
      banner: 'http://lorempixel.com/800/150/cats/4'
      flyer: 'http://lorempixel.com/350/400/nightlife/4'
    empty: -> new Store
      name: ''
      slug: ''
      email: ''
      description: ''
      homePageDescription: ''
      homePageImage: ''
      urlFacebook: ''
      urlTwitter: ''
      phoneNumber: ''
      city: ''
      state: ''
      zip: ''
      otherUrl: ''
      flyer: ''
  user:
    a: ->
      user = new User
        email: 'a@a.com'
        passwordHash: '$2a$10$ZZeLx95w4DiOEq7yixmfdeK7p02C7.mROlGe7w7mAgbGiMZpfhP9a' # hash for 'abc'
        name: 'Some Guy'
        isSeller: false
        stores: []
      user.password = 'abc'
      user
    b: ->
      user = new User
        email: 'b@a.com'
        passwordHash: "$2a$10$s3I2jXWoT5d.oEFVt432T.U9fF1lk4ILFJnIzqq.JyXONDtTNZwlm" # hash for 'def'
        name: 'Other Person'
        isSeller: false
        stores: []
      user.password = 'def'
      user
    c: ->
      user = new User
        email: 'c@a.com'
        passwordHash: '$2a$10$yVMG2zpWEGfKQGPxGD3K8.Uo0yvbMOF9hkD53rJBUkqCalRcQC6HG' # hash for 'ghi'
        name: 'Another Seller'
        isSeller: true
        stores: []
      user.password = 'ghi'
      user
    d: ->
      user = new User
        email: 'd@a.com'
        passwordHash: '$2a$10$ZZeLx95w4DiOEq7yixmfdeK7p02C7.mROlGe7w7mAgbGiMZpfhP9a' # hash for 'abc'
        name: 'Joao Silva'
        isSeller: false
        stores: []
        deliveryAddress:
          street: 'Rua A'
          street2: 'Aclimacao'
          city: 'Sao Paulo'
          state: 'SP'
          zip: '01234-567'
        phoneNumber: '+55 (11) 98765-4321'
      user.password = 'abc'
      user
  order:
    a: -> new Order
      store: exports.generator.store.a()
      items: [
        product: exports.generator.product.a()
        price: exports.generator.product.a().price
        quantity: 1
        totalPrice: exports.generator.product.a().price
      ]
      totalProductsPrice: exports.generator.product.a().price
      shippingCost: 1
      totalSaleAmount: exports.generator.product.a().price + 1
      orderDate: new Date(2013, 0, 1)
      customer: exports.generator.user.d()
      deliveryAddress: exports.generator.user.d().deliveryAddress
    b: -> new Order
      store: exports.generator.store.a()
      items: [
        product: exports.generator.product.b()
        price: exports.generator.product.b().price
        quantity: 1
        totalPrice: exports.generator.product.b().price
      ]
      totalProductsPrice: exports.generator.product.b().price
      shippingCost: 1
      totalSaleAmount: exports.generator.product.b().price + 1
      orderDate: new Date(2013, 0, 5)
      customer: exports.generator.user.d()
      deliveryAddress: exports.generator.user.d().deliveryAddress
