Product   = require '../../app/models/product'
Store     = require '../../app/models/store'
User      = require '../../app/models/user'

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
      description: "Mussum ipsum cacilds, vidis litro abertis. Consetis adipiscings elitis. Pra lá , depois divoltis porris, paradis. Paisis, filhis, espiritis santis. Mé faiz elementum girarzis, nisi eros vermeio, in elementis mé pra quem é amistosis quis leo. Manduma pindureta quium dia nois paga. Sapien in monti palavris qui num significa nadis i pareci latim. Interessantiss quisso pudia ce receita de bolis, mais bolis eu num gostis."
      dimensions:
        height: 10
        width: 20
        depth: 30
      weight: 40
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
      description: "Suco de cevadiss, é um leite divinis, qui tem lupuliz, matis, aguis e fermentis. Interagi no mé, cursus quis, vehicula ac nisi. Aenean vel dui dui. Nullam leo erat, aliquet quis tempus a, posuere ut mi. Ut scelerisque neque et turpis posuere pulvinar pellentesque nibh ullamcorper. Pharetra in mattis molestie, volutpat elementum justo. Aenean ut ante turpis. Pellentesque laoreet mé vel lectus scelerisque interdum cursus velit auctor. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam ac mauris lectus, non scelerisque augue. Aenean justo massa."
      dimensions:
        height: 50
        width: 60
        depth: 70
      weight: 80
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
      description: "Casamentiss faiz malandris se pirulitá, Nam liber tempor cum soluta nobis eleifend option congue nihil imperdiet doming id quod mazim placerat facer possim assum. Lorem ipsum dolor sit amet, consectetuer Ispecialista im mé intende tudis nuam golada, vinho, uiski, carirí, rum da jamaikis, só num pode ser mijis. Adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat."
      dimensions:
        height: 90
        width: 100
        depth:110
      weight: 50
      hasInventory: false
    d: -> new Product
      name: 'name 4'
      slug: 'name_4'
      picture: 'http://lorempixel.com/150/200/cats'
      price: 42.2
      storeName: 'store 1'
      storeSlug: 'store_1'
      tags: ['mno', 'pqr']
      description: "Other Suco de cevadiss, é um leite divinis, qui tem lupuliz, matis, aguis e fermentis. Interagi no mé, cursus quis, vehicula ac nisi. Aenean vel dui dui. Nullam leo erat, aliquet quis tempus a, posuere ut mi. Ut scelerisque neque et turpis posuere pulvinar pellentesque nibh ullamcorper. Pharetra in mattis molestie, volutpat elementum justo. Aenean ut ante turpis. Pellentesque laoreet mé vel lectus scelerisque interdum cursus velit auctor. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam ac mauris lectus, non scelerisque augue. Aenean justo massa."
      dimensions:
        height: 90
        width: 100
        depth: 110
      weight: 120
      hasInventory: true
      inventory: 130
  store:
    a: -> new Store
      name: 'Store 1'
      slug: 'store_1'
      phoneNumber: '(11) 98745-7894'
      city: "São Paulo"
      state: "SP"
      otherUrl: 'http://myotherurl.com'
      banner: 'http://lorempixel.com/800/150/cats'
      flyer: 'http://lorempixel.com/350/400/nightlife/'
    b: -> new Store
      name: 'Store 2'
      slug: 'store_2'
      phoneNumber: '(85) 7788-1111'
      city: "Fortaleza"
      state: "CE"
      otherUrl: 'http://someotherurl.com'
      flyer: 'http://lorempixel.com/350/400/nightlife/'
    c: -> new Store
      name: 'Store 3'
      slug: 'store_3'
      phoneNumber: '(77) 9999-9999'
      city: "Manaus"
      state: "AM"
      otherUrl: 'http://idontownthisstore.com'
      flyer: 'http://lorempixel.com/350/400/nightlife/'
    empty: -> new Store
      name: ''
      slug: ''
      phoneNumber: ''
      city: ""
      state: ""
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
