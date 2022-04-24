import classes from './Auth.module.css';
import {authActions} from '../store/CounterProvider'
import {useDispatch} from 'react-redux'

const Auth = () => {
    const dispatch = useDispatch()
    function onClickHandler(){
        dispatch(authActions.loggedIn())
    }

  return (
    <main className={classes.auth}>
      <section>
        <form>
          <div className={classes.control}>
            <label htmlFor='email'>Email</label>
            <input type='email' id='email' />
          </div>
          <div className={classes.control}>
            <label htmlFor='password'>Password</label>
            <input type='password' id='password' />
          </div>
          <button onClick={onClickHandler}>Login</button>
        </form>
      </section>
    </main>
  );
};

export default Auth;
