define = require('amdefine')(module, requirejs) if (typeof define isnt 'function')
define ->
  generatorc:
    product:
      a: ->
        _id: '1'
        name: 'prod 1'
        slug: 'prod_1'
        picture: 'http://c.jpg'
        pictureThumb: 'http://c_thumb.jpg'
        price: 3.43
        storeName: 'Store 1'
        storeSlug: 'store_1'
        url: 'store_1#prod_1'
        tags: 'abc, def'
        description: "Mussum ipsum cacilds, vidis litro abertis. Consetis adipiscings elitis. Pra lá , depois divoltis porris, paradis. Paisis, filhis, espiritis santis. Mé faiz elementum girarzis, nisi eros vermeio, in elementis mé pra quem é amistosis quis leo. Manduma pindureta quium dia nois paga. Sapien in monti palavris qui num significa nadis i pareci latim. Interessantiss quisso pudia ce receita de bolis, mais bolis eu num gostis."
        height: 10
        width: 20
        depth: 30
        weight: 40
        shippingCharge: true
        shippingHeight: 11
        shippingWidth: 21
        shippingDepth: 31
        shippingWeight: 21
        hasInventory: true
        inventory: 30
      b: ->
        _id: '2'
        name: 'prod 2'
        slug: 'prod_2'
        picture: 'http://d.jpg'
        pictureThumb: 'http://d_thumb.jpg'
        price: 4.56
        storeName: 'Store 1'
        storeSlug: 'store_1'
        url: 'store_1#prod_2'
        tags: 'ghi, jkl'
        description: "Suco de cevadiss, é um leite divinis, qui tem lupuliz, matis, aguis e fermentis. Interagi no mé, cursus quis, vehicula ac nisi. Aenean vel dui dui. Nullam leo erat, aliquet quis tempus a, posuere ut mi. Ut scelerisque neque et turpis posuere pulvinar pellentesque nibh ullamcorper. Pharetra in mattis molestie, volutpat elementum justo. Aenean ut ante turpis. Pellentesque laoreet mé vel lectus scelerisque interdum cursus velit auctor. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam ac mauris lectus, non scelerisque augue. Aenean justo massa."
        height: 50
        width: 60
        depth: 70
        weight: 80
        shippingCharge: false
        shippingHeight: 51
        shippingWidth: 61
        shippingDepth: 71
        shippingWeight: 11
        hasInventory: false
      c: ->
        name: 'name 3'
        slug: 'name_3'
        picture: 'http://lorempixel.com/150/150/cats'
        pictureThumb: 'http://lorempixel.com/150/150/cats_thumb'
        price: 33.33
        storeName: 'Store 2'
        storeSlug: 'store_2'
        tags: 'abc, mno'
        description: "Casamentiss faiz malandris se pirulitá, Nam liber tempor cum soluta nobis eleifend."
        height: 19
        width: 20
        depth: 21
        weight: 5
        shippingCharge: true
        shippingHeight: 20
        shippingWidth: 21
        shippingDepth: 22
        shippingWeight: 6
        hasInventory: false
    store:
      a: ->
        _id: '1'
        name: 'Store 1'
        slug: 'store_1'
        email: 'a@a.com'
        description: "Store Mussum ipsum cacilds, vidis litro abertis. Consetis adipiscings elitis. Pra lá , depois divoltis porris, paradis. Paisis, filhis, espiritis santis. Mé faiz elementum girarzis, nisi eros vermeio, in elementis mé pra quem é amistosis quis leo. Manduma pindureta quium dia nois paga. Sapien in monti palavris qui num significa nadis i pareci latim. Interessantiss quisso pudia ce receita de bolis, mais bolis eu num gostis."
        homePageImage: 'http://lorempixel.com/400/400/nightlife/1'
        urlFacebook: 'fbstore1'
        urlTwitter: 'twstore1'
        phoneNumber: '(11) 98745-7894'
        city: "São Paulo"
        state: "SP"
        zip: "01234-567"
        otherUrl: 'http://myotherurl.com'
        banner: 'http://e.jpg'
        flyer: 'http://lorempixel.com/350/400/nightlife/'
        pagseguro: true
        pagseguroEmail: 'pagseguro@a.com'
        pagseguroToken: 'FFFFFDAFADSFIUADSKFLDSJALA9D0CAA'
      b: ->
        _id: '2'
        name: 'Store 2'
        slug: 'store_2'
        email: 'b@a.com'
        description: "Store Suco de cevadiss, é um leite divinis, qui tem lupuliz, matis, aguis e fermentis. Interagi no mé, cursus quis, vehicula ac nisi. Aenean vel dui dui. Nullam leo erat, aliquet quis tempus a, posuere ut mi. Ut scelerisque neque et turpis posuere pulvinar pellentesque nibh ullamcorper. Pharetra in mattis molestie, volutpat elementum justo. Aenean ut ante turpis. Pellentesque laoreet mé vel lectus scelerisque interdum cursus velit auctor. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam ac mauris lectus, non scelerisque augue. Aenean justo massa."
        homePageImage: 'http://lorempixel.com/400/400/nightlife/2'
        urlFacebook: 'fbstore2'
        urlTwitter: 'twstore2'
        phoneNumber: '(45) 6666-9999'
        city: "São Xilevers"
        state: "AP"
        zip: "04365-000"
        otherUrl: 'http://someurl.com'
        banner: 'http://j.jpg'
        flyer: 'http://lorempixel.com/350/400/nightlife/'
        pagseguro: false
      c: ->
        _id: '3'
        name: 'Store 3'
        slug: 'store_3'
        email: 'c@a.com'
        description: "Store Casamentiss faiz malandris se pirulitá, Nam liber tempor cum soluta nobis eleifend option congue nihil imperdiet doming id quod mazim placerat facer possim assum. Lorem ipsum dolor sit amet, consectetuer Ispecialista im mé intende tudis nuam golada, vinho, uiski, carirí, rum da jamaikis, só num pode ser mijis. Adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat."
        homePageImage: 'http://lorempixel.com/400/400/nightlife/3'
        urlFacebook: 'fbstore3'
        urlTwitter: 'twstore3'
        phoneNumber: '(66) 6666-9999'
        city: "Las Vegas"
        state: "RJ"
        zip: "04234-567"
        otherUrl: 'http://other.com'
        flyer: 'http://lorempixel.com/350/400/nightlife/'
        pagseguro: false
      empty: ->
        _id: ''
        name: ''
        slug: ''
        email: ''
        description: ''
        homePageImage: ''
        urlFacebook: ''
        urlTwitter: ''
        phoneNumber: ''
        city: ""
        state: ""
        otherUrl: ''
        pagseguro: false
