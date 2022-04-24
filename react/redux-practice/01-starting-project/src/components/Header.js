import classes from './Header.module.css';
import {useSelector, useDispatch} from 'react-redux'
import {authActions} from '../store/CounterProvider'

const Header = () => {
    const loggedIn = useSelector(state=>state.auth.loggedIn)
    const dispatch = useDispatch()
    function onClickHandler(){
        dispatch(authActions.loggedOut())
    }

  return (
    <header className={classes.header}>
      <h1>Redux Auth</h1>
        {loggedIn && <nav>
        <ul>
          <li>
            <a href='/'>My Products</a>
          </li>
          <li>
            <a href='/'>My Sales</a>
          </li>
          <li>
            <button onClick = {onClickHandler}>Logout</button>
          </li>
        </ul>
      </nav>}
    </header>
  );
};

export default Header;
