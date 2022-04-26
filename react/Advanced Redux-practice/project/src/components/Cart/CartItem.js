import classes from './CartItem.module.css';
import {useDispatch} from 'react-redux';
import {cartActions} from '../../store/cartSlice';

const CartItem = (props) => {
  const { title, quantity, total, price } = props.item;
  const dispatch = useDispatch()
  function onAddHandler(){
    dispatch(cartActions.addItem({
        id: title,
        totalPrice: total,
        quantity,
        price
    }))
  }

  function onReduceHandler(){
    dispatch(cartActions.reduceItem({
        id: title,
        totalPrice: total,
        quantity,
        price
    }))
  }

  return (
    <li className={classes.item}>
      <header>
        <h3>{title}</h3>
        <div className={classes.price}>
          ${total.toFixed(2)}{' '}
          <span className={classes.itemprice}>(${price.toFixed(2)}/item)</span>
        </div>
      </header>
      <div className={classes.details}>
        <div className={classes.quantity}>
          x <span>{quantity}</span>
        </div>
        <div className={classes.actions}>
          <button onClick ={onReduceHandler}>-</button>
          <button onClick = {onAddHandler}>+</button>
        </div>
      </div>
    </li>
  );
};

export default CartItem;
