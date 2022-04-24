import {useState} from 'react'

import Header from './components/Header/Header'
import Cart from './components/Cart/Cart'
import OrderForm from './components/Cart/OrderForm'
import ConfirmOrder from './components/Cart/ConfirmOrder'
import {CartProvider} from './Storage/CartProvider'

import AvailableMeals from './components/Meals/AvailableMeals'

function App() {
  const [cartValid, setCartValid] = useState(false)
  const [formValid, setFormValid] = useState(false)
  const [confirmValid, setConfirmValid] = useState(false)

  function cartAppear(){
    setCartValid(true)
  }

  function cartDisappear(){
    setCartValid(false)
  }

  function confirmAppear(){
    setConfirmValid(true)
  }

  function confirmDisappear(){
    setConfirmValid(false)
  }

  function formAppear(){
    setFormValid(true)
  }

  function formDisappear(){
    setFormValid(false)
  }

  return (
    <CartProvider>
      {formValid && <OrderForm remove={formDisappear} backToCart = {cartAppear} onConfirmShow = {confirmAppear}/>}
      {cartValid && <Cart remove = {cartDisappear} formAppear = {formAppear}/>}
      {confirmValid && <ConfirmOrder onRemove = {confirmDisappear}/>}
      <Header onAdd = {cartAppear}/>
      <AvailableMeals/>
    </CartProvider>
  );
}

export default App;
