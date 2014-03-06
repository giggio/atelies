Page          = require './seleniumPage'

module.exports = class StoreCartPage extends Page
  visit: (storeSlug) => super "#{storeSlug}/cart"
  quantity: -> @getValue('#cartItems > tbody > tr > td:nth-child(3) input').then runFn parseInt
  name: @::getText.partial '#cartItems > tbody > tr > td:nth-child(2)'
  itemTotalPrice: @::getText.partial '#cartItems > tbody > tr .totalPrice'
  id: @::getAttribute.partial '#cartItems > tbody > tr:first-child', 'data-id'
  rows: -> @findElements('#cartItems tbody tr')
  itemsQuantity: -> @rows().then captureAttribute "length"
  removeItem: (product) => @eval "$('[data-id=#{product._id}] .remove').click()"
  updateQuantity: (product, quantity) =>
    @eval "$('[data-id=#{product._id}] .quantity').val('#{quantity}').change()"
    .then => @eval "$('[data-id=#{product._id}] .updateQuantity').click()"
  clearCart: @::pressButton.partial "#clearCart"
  cartItemsExists: @::hasElement.partial '#cartItems'
  totalPrice: @::getText.partial '#cart #totalPrice'
  clickFinishOrder: @::pressButtonAndWait.partial '#finishOrderCart'
