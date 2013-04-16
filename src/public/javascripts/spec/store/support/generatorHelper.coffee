define ->
  generator:
    product:
      a: ->
        _id: '1'
        name: 'prod 1'
        slug: 'prod_1'
        picture: 'http://c.jpg'
        price: 3.43
        storeName: 'store 1'
        storeSlug: 'store_1'
        url: 'store_1#prod_1'
        tags: 'abc, def'
        description: "Mussum ipsum cacilds, vidis litro abertis. Consetis adipiscings elitis. Pra lá , depois divoltis porris, paradis. Paisis, filhis, espiritis santis. Mé faiz elementum girarzis, nisi eros vermeio, in elementis mé pra quem é amistosis quis leo. Manduma pindureta quium dia nois paga. Sapien in monti palavris qui num significa nadis i pareci latim. Interessantiss quisso pudia ce receita de bolis, mais bolis eu num gostis."
        dimensions:
          height: 10
          width: 20
          depth: 30
        weight: 40
        hasInventory: true
        inventory: 30
      b: ->
        _id: '2'
        name: 'prod 2'
        slug: 'prod_2'
        picture: 'http://d.jpg'
        price: 4.56
        storeName: 'store 1'
        storeSlug: 'store_1'
        url: 'store_1#prod_2'
        tags: 'ghi, jkl'
        description: "Suco de cevadiss, é um leite divinis, qui tem lupuliz, matis, aguis e fermentis. Interagi no mé, cursus quis, vehicula ac nisi. Aenean vel dui dui. Nullam leo erat, aliquet quis tempus a, posuere ut mi. Ut scelerisque neque et turpis posuere pulvinar pellentesque nibh ullamcorper. Pharetra in mattis molestie, volutpat elementum justo. Aenean ut ante turpis. Pellentesque laoreet mé vel lectus scelerisque interdum cursus velit auctor. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam ac mauris lectus, non scelerisque augue. Aenean justo massa."
        dimensions:
          height: 50
          width: 60
          depth: 70
        weight: 80
        hasInventory: false
    store:
      a: ->
        _id: '2'
        name: 'store 1'
        slug: 'store_1'
        phoneNumber: '(11) 98745-7894'
        city: "São Paulo"
        state: "SP"
        otherUrl: 'http://myotherurl.com'
        banner: 'http://e.jpg'
