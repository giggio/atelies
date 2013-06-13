Page          = require './seleniumPage'

module.exports = class StoreCartPage extends Page
  visit: (storeSlug, cb) => super "#{storeSlug}#cart", cb
  quantity: (cb) => @getValue '#cartItems > tbody > tr > td:nth-child(3) input', (v) -> cb parseInt v
  name: @::getText.partial '#cartItems > tbody > tr > td:nth-child(2)'
  id: @::getAttribute.partial '#cartItems > tbody > tr:first-child', 'data-id'
  rows: (cb) -> @findElements('#cartItems tbody tr').then cb
  itemsQuantity: (cb) -> @rows (rows) -> cb rows.length
  removeItem: (product, cb) =>
    @eval "$('[data-id=#{product._id}] .remove').click()", cb
  updateQuantity: (product, quantity, cb) =>
    @eval "$('[data-id=#{product._id}] .quantity').val('#{quantity}').change()", =>
      @eval "$('[data-id=#{product._id}] .updateQuantity').click()", cb
  clearCart: @::pressButton.partial "#clearCart"
  cartItemsExists: @::hasElement.partial '#cartItems'
  totalPrice: @::getText.partial '#cart #totalPrice'
