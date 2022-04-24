import classes from './Counter.module.css';
import {useSelector, useDispatch} from 'react-redux'

import {counterActions} from '../store/CounterProvider'

const Counter = () => {
    const counter = useSelector(state => state.counter.counter)
    const show = useSelector(state => state.counter.counterShow)
    const dispatch = useDispatch()

  const toggleCounterHandler = () => {
    dispatch(counterActions.toggleCounter())
  };

  const incrementCounterHandler = ()=>{
    dispatch(counterActions.increment())
  };

  const decrementCounterHandler = ()=>{
    dispatch(counterActions.decrement())
  }

  const increaseCounterHandler = ()=>{
    dispatch(counterActions.increase(10))
  }

  return (
    <main className={classes.counter}>
      <h1>Redux Counter</h1>
      {show && <div className={classes.value}>-- {counter} --</div>}
      <div className = {classes['user-actions']}>
            <button onClick={incrementCounterHandler}>Increment Counter</button>
            <button onClick={increaseCounterHandler}>Increase Counter</button>
            <button onClick={decrementCounterHandler}>Decrement Counter</button>
            <button onClick={toggleCounterHandler}>Toggle Counter</button>
      </div>

    </main>
  );
};

export default Counter;
