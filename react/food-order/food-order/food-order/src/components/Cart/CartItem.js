
import classes from './CartItem.module.css';

const CartItem = (props) => {
    const cartAdd =()=>{
      props.onAdd({name : props.item.name,
                 price : props.item.price,
                 amount : 1})
    }

    const cartReduce = ()=>{
       props.onReduce({name : props.item.name,
                        price : props.item.price,
                        amount : 1})
    }
  const price = `$${(props.item.amount * props.item.price).toFixed(2)}`;

  return (
    <li className={classes['cart-item']} key = {props.item.name}>
      <div>
        <h2>{props.item.name}</h2>
        <div className={classes.summary}>
          <span className={classes.price}>{price}</span>
          <span className={classes.amount}>x {props.item.amount}</span>
        </div>
      </div>
      <div className={classes.actions}>
        <button onClick={cartReduce}>−</button>
        <button onClick={cartAdd}>+</button>
      </div>
    </li>
  );
};

export default CartItem;