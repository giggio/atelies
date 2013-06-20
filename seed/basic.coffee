server2 = if server? then server else 'localhost'
dbName2 = if dbName? then dbName else 'openstore'
db = connect "#{server2}/#{dbName2}"
db.auth user, password if password?
db.users.remove()
db.users.insert
  email: 'a@a.com'
  passwordHash: '$2a$10$ZZeLx95w4DiOEq7yixmfdeK7p02C7.mROlGe7w7mAgbGiMZpfhP9a' # hash for 'abc'
  name: 'Some Guy'
  isSeller: false
  stores: []
db.users.insert
  email: 'b@a.com'
  passwordHash: "$2a$10$s3I2jXWoT5d.oEFVt432T.U9fF1lk4ILFJnIzqq.JyXONDtTNZwlm" # hash for 'def'
  name: 'Other Person'
  isSeller: false
  stores: []
db.users.insert
  email: 'c@a.com'
  passwordHash: '$2a$10$yVMG2zpWEGfKQGPxGD3K8.Uo0yvbMOF9hkD53rJBUkqCalRcQC6HG' # hash for 'ghi'
  name: 'Another Seller'
  isSeller: true
  stores: []
userSeller = db.users.findOne email:'c@a.com'
db.users.insert
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
user1 = db.users.findOne email:'d@a.com'

db.products.remove()
db.products.insert
  name: 'name 1'
  nameKeywords: ['name', '1']
  slug: 'name_1'
  picture: 'http://lorempixel.com/300/450/cats/1'
  price: 11.1
  storeName: 'store 1'
  storeSlug: 'store_1'
  tags: ['abc', 'def']
  description: "Mussum ipsum cacilds, vidis litro abertis. Consetis adipiscings elitis. Pra lá , depois divoltis porris, paradis. Paisis, filhis, espiritis santis. Mé faiz elementum girarzis, nisi eros vermeio, in elementis mé pra quem é amistosis quis leo. Manduma pindureta quium dia nois paga. Sapien in monti palavris qui num significa nadis i pareci latim. Interessantiss quisso pudia ce receita de bolis, mais bolis eu num gostis."
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
    weight: 5
  hasInventory: true
  inventory: 30
product1 = db.products.findOne name:'name 1'
db.products.insert
  name: 'name 2'
  nameKeywords: ['name', '2']
  slug: 'name_2'
  picture: 'http://lorempixel.com/300/450/cats/2'
  price: 22.2
  storeName: 'store 1'
  storeSlug: 'store_1'
  tags: ['ghi', 'jkl']
  description: "Suco de cevadiss, é um leite divinis, qui tem lupuliz, matis, aguis e fermentis. Interagi no mé, cursus quis, vehicula ac nisi. Aenean vel dui dui. Nullam leo erat, aliquet quis tempus a, posuere ut mi. Ut scelerisque neque et turpis posuere pulvinar pellentesque nibh ullamcorper. Pharetra in mattis molestie, volutpat elementum justo. Aenean ut ante turpis. Pellentesque laoreet mé vel lectus scelerisque interdum cursus velit auctor. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam ac mauris lectus, non scelerisque augue. Aenean justo massa."
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
db.products.insert
  name: 'name 3'
  nameKeywords: ['name', '3']
  slug: 'name_3'
  picture: 'http://lorempixel.com/300/450/cats/3'
  price: 33.33
  storeName: 'store 2'
  storeSlug: 'store_2'
  tags: ['abc', 'mno']
  description: "Casamentiss faiz malandris se pirulitá, Nam liber tempor cum soluta nobis eleifend option congue nihil imperdiet doming id quod mazim placerat facer possim assum. Lorem ipsum dolor sit amet, consectetuer Ispecialista im mé intende tudis nuam golada, vinho, uiski, carirí, rum da jamaikis, só num pode ser mijis. Adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat."
  dimensions:
    height: 19
    width: 20
    depth:21
  weight: 5
  shipping:
    dimensions:
      height: 20
      width: 21
      depth: 22
    weight: 6
  hasInventory: false
db.products.insert
  name: 'name 4'
  nameKeywords: ['name', '4']
  slug: 'name_4'
  picture: 'http://lorempixel.com/300/450/cats/4'
  price: 42.2
  storeName: 'store 1'
  storeSlug: 'store_1'
  tags: ['mno', 'pqr']
  description: "Other Suco de cevadiss, é um leite divinis, qui tem lupuliz, matis, aguis e fermentis. Interagi no mé, cursus quis, vehicula ac nisi. Aenean vel dui dui. Nullam leo erat, aliquet quis tempus a, posuere ut mi. Ut scelerisque neque et turpis posuere pulvinar pellentesque nibh ullamcorper. Pharetra in mattis molestie, volutpat elementum justo. Aenean ut ante turpis. Pellentesque laoreet mé vel lectus scelerisque interdum cursus velit auctor. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam ac mauris lectus, non scelerisque augue. Aenean justo massa."
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
db.products.insert
  name: 'name 5'
  nameKeywords: ['name', '5']
  slug: 'name_5'
  picture: 'http://lorempixel.com/300/450/cats/5'
  price: 52.2
  storeName: 'store 2'
  storeSlug: 'store_2'
  tags: ['mno', 'pqr']
  description: "Other Suco de cevadiss, é um leite divinis, qui tem lupuliz, matis, aguis e fermentis. Interagi no mé, cursus quis, vehicula ac nisi. Aenean vel dui dui. Nullam leo erat, aliquet quis tempus a, posuere ut mi. Ut scelerisque neque et turpis posuere pulvinar pellentesque nibh ullamcorper. Pharetra in mattis molestie, volutpat elementum justo. Aenean ut ante turpis. Pellentesque laoreet mé vel lectus scelerisque interdum cursus velit auctor. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam ac mauris lectus, non scelerisque augue. Aenean justo massa."
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
db.products.insert
  name: 'name 6'
  nameKeywords: ['name', '6']
  slug: 'name_6'
  picture: 'http://lorempixel.com/300/450/cats/6'
  price: 62.2
  storeName: 'store 1'
  storeSlug: 'store_1'
  tags: ['mno', 'pqr']
  description: "Other Suco de cevadiss, é um leite divinis, qui tem lupuliz, matis, aguis e fermentis. Interagi no mé, cursus quis, vehicula ac nisi. Aenean vel dui dui. Nullam leo erat, aliquet quis tempus a, posuere ut mi. Ut scelerisque neque et turpis posuere pulvinar pellentesque nibh ullamcorper. Pharetra in mattis molestie, volutpat elementum justo. Aenean ut ante turpis. Pellentesque laoreet mé vel lectus scelerisque interdum cursus velit auctor. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam ac mauris lectus, non scelerisque augue. Aenean justo massa."
  dimensions:
    height: 90
    width: 100
    depth: 110
  weight: 120
  shipping:
    dimensions:
      height: 91
      width: 101
      depth: 111
    weight: 121
  hasInventory: true
  inventory: 130
db.products.insert
  name: 'Some Fancier Name 7'
  nameKeywords: ['some', 'fancier', 'name', '7']
  slug: 'some_fancier_name_7'
  picture: 'http://lorempixel.com/300/450/cats/7'
  price: 72.2
  storeName: 'store 1'
  storeSlug: 'store_1'
  tags: ['mno', 'pqr']
  description: "Other Suco de cevadiss, é um leite divinis, qui tem lupuliz, matis, aguis e fermentis. Interagi no mé, cursus quis, vehicula ac nisi. Aenean vel dui dui. Nullam leo erat, aliquet quis tempus a, posuere ut mi. Ut scelerisque neque et turpis posuere pulvinar pellentesque nibh ullamcorper. Pharetra in mattis molestie, volutpat elementum justo. Aenean ut ante turpis. Pellentesque laoreet mé vel lectus scelerisque interdum cursus velit auctor. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam ac mauris lectus, non scelerisque augue. Aenean justo massa."
  dimensions:
    height: 15
    width: 16
    depth: 17
  weight: 12
  shipping:
    dimensions:
      height: 16
      width: 17
      depth: 18
    weight: 13
  hasInventory: true
  inventory: 130
for i in [8..25]
  pictureId = i - Math.floor(i/10, 0) * 10
  pictureId = 10 if i is 0
  db.products.insert
    name: "Name #{i}"
    nameKeywords: ['name', i.toString()]
    slug: "name_#{i}"
    picture: "http://lorempixel.com/300/450/cats/#{pictureId}"
    price: 62.2
    storeName: 'store 1'
    storeSlug: 'store_1'
    tags: ['mno', 'pqr']
    description: "Other Suco de cevadiss, é um leite divinis, qui tem lupuliz, matis, aguis e fermentis. Interagi no mé, cursus quis, vehicula ac nisi. Aenean vel dui dui. Nullam leo erat, aliquet quis tempus a, posuere ut mi. Ut scelerisque neque et turpis posuere pulvinar pellentesque nibh ullamcorper. Pharetra in mattis molestie, volutpat elementum justo. Aenean ut ante turpis. Pellentesque laoreet mé vel lectus scelerisque interdum cursus velit auctor. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam ac mauris lectus, non scelerisque augue. Aenean justo massa."
    dimensions:
      height: 16
      width: 17
      depth: 18
    weight: 13
    shipping:
      dimensions:
        height: 17
        width: 18
        depth: 19
      weight: 14
    hasInventory: true
    inventory: 130
db.products.ensureIndex { description:'text' }, { default_language: "portuguese" }
db.products.ensureIndex { nameKeywords: 1 }
db.stores.remove()
db.stores.insert
  name: 'Store 1'
  nameKeywords: ['store', '1']
  slug: 'store_1'
  email: 'a@a.com'
  description: "Store Mussum ipsum cacilds, vidis litro abertis. Consetis adipiscings elitis. Pra lá , depois divoltis porris, paradis. Paisis, filhis, espiritis santis. Mé faiz elementum girarzis, nisi eros vermeio, in elementis mé pra quem é amistosis quis leo. Manduma pindureta quium dia nois paga. Sapien in monti palavris qui num significa nadis i pareci latim. Interessantiss quisso pudia ce receita de bolis, mais bolis eu num gostis."
  homePageDescription: "HP Store Mussum ipsum cacilds, vidis litro abertis. Consetis adipiscings elitis. Pra lá , depois divoltis porris, paradis. Paisis, filhis, espiritis santis. Mé faiz elementum girarzis, nisi eros vermeio, in elementis mé pra quem é amistosis quis leo. Manduma pindureta quium dia nois paga. Sapien in monti palavris qui num significa nadis i pareci latim. Interessantiss quisso pudia ce receita de bolis, mais bolis eu num gostis."
  homePageImage: 'http://lorempixel.com/400/400/nightlife/1'
  urlFacebook: 'fbstore1'
  urlTwitter: 'twstore1'
  phoneNumber: '(11) 98745-7894'
  city: "São Paulo"
  state: "SP"
  zip: "01234-567"
  otherUrl: 'http://myotherurl.com'
  banner: 'http://lorempixel.com/800/150/cats/1'
store1 = db.stores.findOne(slug:'store_1')
storeId = store1._id
userSeller.stores.push storeId
db.stores.insert
  name: 'Store 2'
  nameKeywords: ['store', '2']
  slug: 'store_2'
  email: 'b@a.com'
  description: "Store Suco de cevadiss, é um leite divinis, qui tem lupuliz, matis, aguis e fermentis. Interagi no mé, cursus quis, vehicula ac nisi. Aenean vel dui dui. Nullam leo erat, aliquet quis tempus a, posuere ut mi. Ut scelerisque neque et turpis posuere pulvinar pellentesque nibh ullamcorper. Pharetra in mattis molestie, volutpat elementum justo. Aenean ut ante turpis. Pellentesque laoreet mé vel lectus scelerisque interdum cursus velit auctor. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam ac mauris lectus, non scelerisque augue. Aenean justo massa."
  homePageDescription: "HP Store Suco de cevadiss, é um leite divinis, qui tem lupuliz, matis, aguis e fermentis. Interagi no mé, cursus quis, vehicula ac nisi. Aenean vel dui dui. Nullam leo erat, aliquet quis tempus a, posuere ut mi. Ut scelerisque neque et turpis posuere pulvinar pellentesque nibh ullamcorper. Pharetra in mattis molestie, volutpat elementum justo. Aenean ut ante turpis. Pellentesque laoreet mé vel lectus scelerisque interdum cursus velit auctor. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam ac mauris lectus, non scelerisque augue. Aenean justo massa."
  homePageImage: 'http://lorempixel.com/400/400/nightlife/2'
  urlFacebook: 'fbstore2'
  urlTwitter: 'twstore2'
  phoneNumber: '(85) 7788-1111'
  city: "Fortaleza"
  state: "CE"
  zip: "04365-000"
  otherUrl: 'http://someotherurl.com'
  flyer: 'http://lorempixel.com/350/400/nightlife/2'
storeId2 = db.stores.findOne(slug:'store_2')._id
userSeller.stores.push storeId2
db.stores.insert
  name: 'Store 3'
  nameKeywords: ['store', '3']
  slug: 'store_3'
  email: 'c@a.com'
  description: "Store Casamentiss faiz malandris se pirulitá, Nam liber tempor cum soluta nobis eleifend option congue nihil imperdiet doming id quod mazim placerat facer possim assum. Lorem ipsum dolor sit amet, consectetuer Ispecialista im mé intende tudis nuam golada, vinho, uiski, carirí, rum da jamaikis, só num pode ser mijis. Adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat."
  homePageDescription: "HP Store Casamentiss faiz malandris se pirulitá, Nam liber tempor cum soluta nobis eleifend option congue nihil imperdiet doming id quod mazim placerat facer possim assum. Lorem ipsum dolor sit amet, consectetuer Ispecialista im mé intende tudis nuam golada, vinho, uiski, carirí, rum da jamaikis, só num pode ser mijis. Adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat."
  homePageImage: 'http://lorempixel.com/400/400/nightlife/3'
  urlFacebook: 'fbstore3'
  urlTwitter: 'twstore3'
  phoneNumber: '(77) 9999-9999'
  city: "Manaus"
  state: "AM"
  zip: "04234-567"
  otherUrl: 'http://idontownthisstore.com'
  flyer: 'http://lorempixel.com/350/400/nightlife/3'
db.stores.insert
  name: 'Some Fancy Name'
  nameKeywords: ['some', 'fancy', 'name']
  slug: 'some_fancy_name'
  email: 'd@a.com'
  description: "Store Muito other suco de cevadiss, é um leite divinis, qui tem lupuliz, matis, aguis e fermentis. Interagi no mé, cursus quis, vehicula ac nisi. Aenean vel dui dui. Nullam leo erat, aliquet quis tempus a, posuere ut mi. Ut scelerisque neque et turpis posuere pulvinar pellentesque nibh ullamcorper. Pharetra in mattis molestie, volutpat elementum justo. Aenean ut ante turpis. Pellentesque laoreet mé vel lectus scelerisque interdum cursus velit auctor. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam ac mauris lectus, non scelerisque augue. Aenean justo massa."
  homePageDescription: "HP Store Muito other suco de cevadiss, é um leite divinis, qui tem lupuliz, matis, aguis e fermentis. Interagi no mé, cursus quis, vehicula ac nisi. Aenean vel dui dui. Nullam leo erat, aliquet quis tempus a, posuere ut mi. Ut scelerisque neque et turpis posuere pulvinar pellentesque nibh ullamcorper. Pharetra in mattis molestie, volutpat elementum justo. Aenean ut ante turpis. Pellentesque laoreet mé vel lectus scelerisque interdum cursus velit auctor. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam ac mauris lectus, non scelerisque augue. Aenean justo massa."
  homePageImage: 'http://lorempixel.com/400/400/nightlife/4'
  urlFacebook: 'fbsomefancyname'
  urlTwitter: 'twsomefancyname'
  phoneNumber: '(37) 9999-9999'
  city: "Campo Grande"
  state: "MS"
  zip: "04334-567"
  otherUrl: 'http://somestorefromms.com'
  flyer: 'http://lorempixel.com/350/400/nightlife/4'
for i in [4..15]
  pictureId = i - Math.floor(i/10, 0) * 10
  pictureId = 10 if i is 0
  db.stores.insert
    name: "Store #{i}"
    nameKeywords: ['store', i.toString()]
    slug: "store_#{i}"
    email: "a#{i}@a.com"
    description: "Store#{i} Mussum ipsum cacilds, vidis litro abertis. Consetis adipiscings elitis. Pra lá , depois divoltis porris, paradis. Paisis, filhis, espiritis santis. Mé faiz elementum girarzis, nisi eros vermeio, in elementis mé pra quem é amistosis quis leo. Manduma pindureta quium dia nois paga. Sapien in monti palavris qui num significa nadis i pareci latim. Interessantiss quisso pudia ce receita de bolis, mais bolis eu num gostis."
    homePageDescription: "HP Store#{i} Mussum ipsum cacilds, vidis litro abertis. Consetis adipiscings elitis. Pra lá , depois divoltis porris, paradis. Paisis, filhis, espiritis santis. Mé faiz elementum girarzis, nisi eros vermeio, in elementis mé pra quem é amistosis quis leo. Manduma pindureta quium dia nois paga. Sapien in monti palavris qui num significa nadis i pareci latim. Interessantiss quisso pudia ce receita de bolis, mais bolis eu num gostis."
    homePageImage: "http://lorempixel.com/400/400/nightlife/4#{i}"
    urlFacebook: "fbstore#{i}"
    urlTwitter: "twstore#{i}"
    phoneNumber: "(#{i}) 98745-7894"
    city: "São Paulo"
    state: "SP"
    zip: "01234-667"
    otherUrl: 'http://myotherurl.com'
    banner: "http://lorempixel.com/800/150/cats/#{pictureId}"
    flyer: "http://lorempixel.com/350/400/nightlife/#{pictureId}"
  store = db.stores.findOne slug:"store_#{i}"
  userSeller.stores.push store._id
db.users.save userSeller
db.orders.remove()
db.orders.insert
  store: store1._id
  items: [
    product: product1._id
    price: product1.price
    quantity: 1
    totalPrice: product1.price
  ]
  totalProductsPrice: product1.price
  shippingCost: 1
  totalSaleAmount: product1.price + 1
  orderDate: new Date(2013, 0, 1)
  customer: user1._id
  deliveryAddress: user1.deliveryAddress
db.orders.ensureIndex { customer: 1 }
