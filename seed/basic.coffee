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
  loginError: 0
  verified: true
db.users.insert
  email: 'b@a.com'
  passwordHash: "$2a$10$s3I2jXWoT5d.oEFVt432T.U9fF1lk4ILFJnIzqq.JyXONDtTNZwlm" # hash for 'def'
  name: 'Other Person'
  isSeller: false
  stores: []
  loginError: 0
  verified: true
db.users.insert
  email: 'c@a.com'
  passwordHash: '$2a$10$yVMG2zpWEGfKQGPxGD3K8.Uo0yvbMOF9hkD53rJBUkqCalRcQC6HG' # hash for 'ghi'
  name: 'Another Seller'
  isSeller: true
  stores: []
  loginError: 0
  verified: true
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
  loginError: 0
  verified: true
db.users.insert
  email: 'e@a.com'
  passwordHash: '$2a$10$ZZeLx95w4DiOEq7yixmfdeK7p02C7.mROlGe7w7mAgbGiMZpfhP9a' # hash for 'abc'
  name: 'Some E Guy'
  isSeller: false
  stores: []
  loginError: 0
  verified: false
user1 = db.users.findOne email:'d@a.com'
user2 = db.users.findOne email:'c@a.com'
db.users.ensureIndex { email: 1 }
db.users.ensureIndex { facebookId: 1 }

db.products.remove()
db.products.insert
  name: 'name 1'
  nameKeywords: ['name', '1']
  slug: 'name_1'
  picture: 'https://s3.amazonaws.com/ateliesteste/store_1/products/171326565789058800912925501121208000.jpg'
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
    applies: true
    charge: true
    dimensions:
      height: 12
      width: 13
      depth: 18
    weight: 5
  hasInventory: true
  inventory: 30
  random: Math.random()
  comments: [
    {
    body: "Some really long comment. Aenean vel dui dui. Nullam leo erat, aliquet quis tempus a, posuere ut mi. Ut scelerisque neque et turpis posuere pulvinar pellentesque nibh ullamcorper. Pharetra in mattis molestie, volutpat elementum justo. Aenean ut ante turpis. Pellentesque laoreet mé vel lectus scelerisque interdum cursus velit auctor. Lorem ipsum dolor sit amet, consectetur adipiscing elit.\n\n***Again*** really long comment. Aenean vel dui dui. Nullam leo erat, aliquet quis tempus a, posuere ut mi. Ut scelerisque neque et turpis posuere pulvinar pellentesque nibh ullamcorper. Pharetra in mattis molestie, volutpat elementum justo. Aenean ut ante turpis. Pellentesque laoreet mé vel lectus scelerisque interdum cursus velit auctor. Lorem ipsum dolor sit amet, consectetur adipiscing elit."
    date: new Date(2013, 0, 1)
    user: user1
    userName: user1.name
    userEmail: user1.email
    },
    {
    body: "Other long comment. Aenean vel dui dui. Nullam leo erat, aliquet quis tempus a, posuere ut mi. Ut scelerisque neque et turpis posuere pulvinar pellentesque nibh ullamcorper. Pharetra in mattis molestie, volutpat elementum justo. Aenean ut ante turpis. Pellentesque laoreet mé vel lectus scelerisque interdum cursus velit auctor. Lorem ipsum dolor sit amet, consectetur adipiscing elit."
    date: new Date(2013, 1, 2)
    user: user2
    userName: user2.name
    userEmail: user2.email
    }
  ]
product1 = db.products.findOne name:'name 1'
db.products.insert
  name: 'name 2'
  nameKeywords: ['name', '2']
  slug: 'name_2'
  picture: 'https://s3.amazonaws.com/ateliesteste/store_1/products/537971107754856300194540178403258340.jpg'
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
    applies: true
    charge: false
    dimensions:
      height: 16
      width: 17
      depth: 18
    weight: 9
  hasInventory: true
  inventory: 40
  random: Math.random()
db.products.insert
  name: 'name 3'
  nameKeywords: ['name', '3']
  slug: 'name_3'
  picture: 'https://s3.amazonaws.com/ateliesteste/store_1/products/697575170779600800359621327370405200.jpg'
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
    applies: false
    charge: true
    dimensions:
      height: 20
      width: 21
      depth: 22
    weight: 6
  hasInventory: false
  random: Math.random()
db.products.insert
  name: 'name 4'
  nameKeywords: ['name', '4']
  slug: 'name_4'
  picture: 'https://s3.amazonaws.com/ateliesteste/store_1/products/69368822034448380358378419186919940.jpg'
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
    applies: true
    charge: true
    dimensions:
      height: 20
      width: 21
      depth: 22
    weight: 13
  hasInventory: true
  inventory: 130
  random: Math.random()
db.products.insert
  name: 'name 5'
  nameKeywords: ['name', '5']
  slug: 'name_5'
  picture: 'https://s3.amazonaws.com/ateliesteste/store_1/products/306489950977265860824955702992156200.jpg'
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
    applies: true
    charge: true
    dimensions:
      height: 20
      width: 21
      depth: 22
    weight: 13
  hasInventory: true
  inventory: 130
  random: Math.random()
db.products.insert
  name: 'name 6'
  nameKeywords: ['name', '6']
  slug: 'name_6'
  picture: 'https://s3.amazonaws.com/ateliesteste/store_1/products/581893865950405600315305696800351170.jpg'
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
    applies: true
    charge: true
    dimensions:
      height: 91
      width: 101
      depth: 111
    weight: 121
  hasInventory: true
  inventory: 130
  random: Math.random()
db.products.insert
  name: 'Some Fancier Name 7'
  nameKeywords: ['some', 'fancier', 'name', '7']
  slug: 'some_fancier_name_7'
  picture: 'https://s3.amazonaws.com/ateliesteste/store_1/products/497979291947558500646980655146762800.jpg'
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
    applies: true
    charge: true
    dimensions:
      height: 16
      width: 17
      depth: 18
    weight: 13
  hasInventory: true
  inventory: 130
  random: Math.random()
db.products.insert
  name: 'Some Fancier Name 8'
  nameKeywords: ['some', 'fancier', 'name', '8']
  slug: 'some_fancier_name_8'
  picture: 'https://s3.amazonaws.com/ateliesteste/store_1/products/497979291947558500646980655146762800.jpg'
  price: 82.2
  storeName: 'store 1'
  storeSlug: 'store_1'
  tags: ['mno', 'pqr']
  description: "Ather Suco de cevadiss, é um leite divinis, qui tem lupuliz, matis, aguis e fermentis. Interagi no mé, cursus quis, vehicula ac nisi. Aenean vel dui dui. Nullam leo erat, aliquet quis tempus a, posuere ut mi. Ut scelerisque neque et turpis posuere pulvinar pellentesque nibh ullamcorper. Pharetra in mattis molestie, volutpat elementum justo. Aenean ut ante turpis. Pellentesque laoreet mé vel lectus scelerisque interdum cursus velit auctor. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam ac mauris lectus, non scelerisque augue. Aenean justo massa."
  dimensions:
    height: 15
    width: 16
    depth: 17
  weight: 12
  shipping:
    applies: false
    charge: false
    dimensions:
      height: 16
      width: 17
      depth: 18
    weight: 13
  hasInventory: true
  inventory: 130
  random: Math.random()
for i in [8..25]
  pictureId = i - Math.floor(i/10, 0) * 10
  pictureId = 10 if i is 0
  db.products.insert
    name: "Name #{i}"
    nameKeywords: ['name', i.toString()]
    slug: "name_#{i}"
    picture: "https://s3.amazonaws.com/ateliesteste/store_1/products/119340668199583890867460034321993600.jpg"
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
      applies: true
      charge: true
      dimensions:
        height: 17
        width: 18
        depth: 19
      weight: 14
    hasInventory: true
    inventory: 130
    random: Math.random()
db.products.ensureIndex { description:'text' }, { default_language: "portuguese" }
db.products.ensureIndex { nameKeywords: 1 }
db.products.ensureIndex { slug: 1 }
db.stores.remove()
db.stores.insert
  name: 'Store 1'
  nameKeywords: ['store', '1']
  slug: 'store_1'
  email: 'a@a.com'
  description: "Store Mussum ipsum cacilds, vidis litro abertis. Consetis adipiscings elitis. Pra lá , depois divoltis porris, paradis. Paisis, filhis, espiritis santis. Mé faiz elementum girarzis, nisi eros vermeio, in elementis mé pra quem é amistosis quis leo. Manduma pindureta quium dia nois paga. Sapien in monti palavris qui num significa nadis i pareci latim. Interessantiss quisso pudia ce receita de bolis, mais bolis eu num gostis."
  homePageDescription: "HP Store Mussum ipsum cacilds, vidis litro abertis. Consetis adipiscings elitis. Pra lá , depois divoltis porris, paradis. Paisis, filhis, espiritis santis. Mé faiz elementum girarzis, nisi eros vermeio, in elementis mé pra quem é amistosis quis leo. Manduma pindureta quium dia nois paga. Sapien in monti palavris qui num significa nadis i pareci latim. Interessantiss quisso pudia ce receita de bolis, mais bolis eu num gostis."
  homePageImage: 'https://s3.amazonaws.com/ateliesteste/store_1/store/808719296241179100238743254682049150.jpg'
  urlFacebook: 'fbstore1'
  urlTwitter: 'twstore1'
  phoneNumber: '(11) 98745-7894'
  city: "São Paulo"
  state: "SP"
  zip: "01234-567"
  otherUrl: 'http://myotherurl.com'
  banner: 'https://s3.amazonaws.com/ateliesteste/store_1/store/6432062247768044242338555399328480.jpg'
  flyer: 'https://s3.amazonaws.com/ateliesteste/store_1/store/236652196617797020858783057425171200.jpg'
  pmtGateways:
    pagseguro:
      email: 'pagseguro@a.com'
      token: 'FFFFFDAFADSFIUADSKFLDSJALA9D0CAA'
  random: Math.random()
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
  homePageImage: 'https://s3.amazonaws.com/ateliesteste/store_2/store/309018768602982140848002398153767000.jpg'
  urlFacebook: 'fbstore2'
  urlTwitter: 'twstore2'
  phoneNumber: '(85) 7788-1111'
  city: "Fortaleza"
  state: "CE"
  zip: "04365-000"
  otherUrl: 'http://someotherurl.com'
  banner: 'https://s3.amazonaws.com/ateliesteste/store_1/store/6432062247768044242338555399328480.jpg'
  flyer: 'https://s3.amazonaws.com/ateliesteste/store_2/store/503898129332810600307476012269035000.jpg'
  pmtGateways: {}
  random: Math.random()
storeId2 = db.stores.findOne(slug:'store_2')._id
userSeller.stores.push storeId2
db.stores.insert
  name: 'Store 3'
  nameKeywords: ['store', '3']
  slug: 'store_3'
  email: 'c@a.com'
  description: "Store Casamentiss faiz malandris se pirulitá, Nam liber tempor cum soluta nobis eleifend option congue nihil imperdiet doming id quod mazim placerat facer possim assum. Lorem ipsum dolor sit amet, consectetuer Ispecialista im mé intende tudis nuam golada, vinho, uiski, carirí, rum da jamaikis, só num pode ser mijis. Adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat."
  homePageDescription: "HP Store Casamentiss faiz malandris se pirulitá, Nam liber tempor cum soluta nobis eleifend option congue nihil imperdiet doming id quod mazim placerat facer possim assum. Lorem ipsum dolor sit amet, consectetuer Ispecialista im mé intende tudis nuam golada, vinho, uiski, carirí, rum da jamaikis, só num pode ser mijis. Adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat."
  homePageImage: 'https://s3.amazonaws.com/ateliesteste/store_3/store/396625304594635970890163169475272300.jpg'
  urlFacebook: 'fbstore3'
  urlTwitter: 'twstore3'
  phoneNumber: '(77) 9999-9999'
  city: "Manaus"
  state: "AM"
  zip: "04234-567"
  otherUrl: 'http://idontownthisstore.com'
  banner: 'https://s3.amazonaws.com/ateliesteste/store_3/store/759137748274952200984912005718797400.jpg'
  flyer: 'https://s3.amazonaws.com/ateliesteste/store_3/store/519919875310733900163886155933141700.jpg'
  pmtGateways: {}
  random: Math.random()
db.stores.insert
  name: 'Some Fancy Name'
  nameKeywords: ['some', 'fancy', 'name']
  slug: 'some_fancy_name'
  email: 'd@a.com'
  description: "Store Muito other suco de cevadiss, é um leite divinis, qui tem lupuliz, matis, aguis e fermentis. Interagi no mé, cursus quis, vehicula ac nisi. Aenean vel dui dui. Nullam leo erat, aliquet quis tempus a, posuere ut mi. Ut scelerisque neque et turpis posuere pulvinar pellentesque nibh ullamcorper. Pharetra in mattis molestie, volutpat elementum justo. Aenean ut ante turpis. Pellentesque laoreet mé vel lectus scelerisque interdum cursus velit auctor. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam ac mauris lectus, non scelerisque augue. Aenean justo massa."
  homePageDescription: "HP Store Muito other suco de cevadiss, é um leite divinis, qui tem lupuliz, matis, aguis e fermentis. Interagi no mé, cursus quis, vehicula ac nisi. Aenean vel dui dui. Nullam leo erat, aliquet quis tempus a, posuere ut mi. Ut scelerisque neque et turpis posuere pulvinar pellentesque nibh ullamcorper. Pharetra in mattis molestie, volutpat elementum justo. Aenean ut ante turpis. Pellentesque laoreet mé vel lectus scelerisque interdum cursus velit auctor. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam ac mauris lectus, non scelerisque augue. Aenean justo massa."
  homePageImage: 'https://s3.amazonaws.com/ateliesteste/store_4/store/465055665234103800952865870436653400.jpg'
  urlFacebook: 'fbsomefancyname'
  urlTwitter: 'twsomefancyname'
  phoneNumber: '(37) 9999-9999'
  city: "Campo Grande"
  state: "MS"
  zip: "04334-567"
  otherUrl: 'http://somestorefromms.com'
  banner: 'https://s3.amazonaws.com/ateliesteste/store_4/store/977493978571146800762570540187880400.jpg'
  flyer: 'https://s3.amazonaws.com/ateliesteste/store_4/store/186986845219507800735144682228565200.jpg'
  pmtGateways: {}
  random: Math.random()
db.stores.insert
  name: 'Some Other Fancy Name'
  nameKeywords: ['some', 'other', 'fancy', 'name']
  slug: 'some_other_fancy_name'
  email: 'e@a.com'
  description: "A Store Muito other suco de cevadiss, é um leite divinis, qui tem lupuliz, matis, aguis e fermentis. Interagi no mé, cursus quis, vehicula ac nisi. Aenean vel dui dui. Nullam leo erat, aliquet quis tempus a, posuere ut mi. Ut scelerisque neque et turpis posuere pulvinar pellentesque nibh ullamcorper. Pharetra in mattis molestie, volutpat elementum justo. Aenean ut ante turpis. Pellentesque laoreet mé vel lectus scelerisque interdum cursus velit auctor. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam ac mauris lectus, non scelerisque augue. Aenean justo massa."
  homePageDescription: "IHP Store Muito other suco de cevadiss, é um leite divinis, qui tem lupuliz, matis, aguis e fermentis. Interagi no mé, cursus quis, vehicula ac nisi. Aenean vel dui dui. Nullam leo erat, aliquet quis tempus a, posuere ut mi. Ut scelerisque neque et turpis posuere pulvinar pellentesque nibh ullamcorper. Pharetra in mattis molestie, volutpat elementum justo. Aenean ut ante turpis. Pellentesque laoreet mé vel lectus scelerisque interdum cursus velit auctor. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam ac mauris lectus, non scelerisque augue. Aenean justo massa."
  homePageImage: 'https://s3.amazonaws.com/ateliesteste/store_4/store/465055665234103800952865870436653400.jpg'
  urlFacebook: 'fbsomeotherfancyname'
  urlTwitter: 'twsomeotherfancyname'
  phoneNumber: '(47) 9999-9999'
  city: "Campo Grande"
  state: "MS"
  zip: "04334-567"
  otherUrl: 'http://somestorefromms.com'
  banner: 'https://s3.amazonaws.com/ateliesteste/store_4/store/977493978571146800762570540187880400.jpg'
  pmtGateways: {}
  random: Math.random()
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
    homePageImage: "https://s3.amazonaws.com/ateliesteste/store_5/store/802396552870050000798405606066808000.jpg"
    urlFacebook: "fbstore#{i}"
    urlTwitter: "twstore#{i}"
    phoneNumber: "(#{i}) 98745-7894"
    city: "São Paulo"
    state: "SP"
    zip: "01234-667"
    otherUrl: 'http://myotherurl.com'
    banner: "https://s3.amazonaws.com/ateliesteste/store_5/store/67713805800303820043159248307347300.jpg"
    flyer: "https://s3.amazonaws.com/ateliesteste/store_5/store/866178757045418000837425043340772400.jpg"
    pmtGateways: {}
    random: Math.random()
  store = db.stores.findOne slug:"store_#{i}"
  userSeller.stores.push store._id
db.stores.ensureIndex { slug: 1 }
db.users.save userSeller
db.orders.remove()
db.orders.insert
  store: store1._id
  items: [
    product: product1._id
    name: product1.name
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
  paymentType: 'directSell'
db.orders.ensureIndex { customer: 1 }
