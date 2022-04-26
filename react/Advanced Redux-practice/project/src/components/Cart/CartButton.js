import classes from './CartButton.module.css';
import {useSelector, useDispatch} from 'react-redux'
import {toggleActions} from '../../store/toggleSlice'

const CartButton = (props) => {
  const number = useSelector(store=>store.cart.totalQuantity)
  const dispatch = useDispatch()
  function onToggle(){
    dispatch(toggleActions.toggle())
  }
  return (
    <button className={classes.button} onClick = {onToggle}>
      <span>My Cart</span>
      <span className={classes.badge}>{number}</span>
    </button>
  );
};

export default CartButton;
