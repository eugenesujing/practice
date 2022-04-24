import Modal from '../../UI/Modal'
import classes from './Cart.module.css'
import CartItem from './CartItem'
import CartContext from '../../Storage/CartProvider'
import {useContext} from 'react'

function Cart(props){
  const ctx = useContext(CartContext)
  //An alternative way to add functions to buttons
  //when this function is invoked, it will always use the args provided in the bind()
/*  const cartItemRemoveHandler = (id) => {
      cartCtx.removeItem(id);
    };

    const cartItemAddHandler = (item) => {
      cartCtx.addItem({ ...item, amount: 1 });
    };

    const cartItems = (
      <ul className={classes['cart-items']}>
        {cartCtx.items.map((item) => (
          <CartItem
            key={item.id}
            name={item.name}
            amount={item.amount}
            price={item.price}
            onRemove={cartItemRemoveHandler.bind(null, item.id)}
            onAdd={cartItemAddHandler.bind(null, item)}
          />
        ))}
      </ul>
    );*/
  const goToForm = ()=>{
    props.remove()
    props.formAppear()
  }
  const cartitem = ctx.items.map((item)=>{ return <CartItem key = {item.name + item.amount} item = {item} onAdd = {ctx.onAdd} onReduce = {ctx.onReduce}/>})
  const total = ctx.items.reduce((prev, curr)=>{
        return prev + curr.price * curr.amount
  },0)
    return<Modal onAdd = {props.appear} onRemove = {props.remove}>
        <ul className = {classes['cart-items']}>
            {cartitem}
        </ul>
        <div className = {classes.total}>
            <h3>Total Amount</h3>
            <h3>${total.toFixed(2)}</h3>
        </div>
        <div className = {classes.actions}>
            <button className = {classes['button--alt']} onClick = {props.remove}>Close</button>
            <button className = {classes.button} onClick = {goToForm}>Order</button>
        </div>
    </Modal>
}

export default Cart