import React, {useContext} from 'react';

import classes from './Navigation.module.css';
import AuthContext from '../Wrapper/AuthProvider'
import Button from '../UI/Button/Button'

const Navigation = (props) => {
  const ctx = useContext(AuthContext)

  return (
    <nav className={classes.nav}>
      <ul>
        {ctx.isLoggedIn && (
          <li>
            <a href="/">Users</a>
          </li>
        )}
        {ctx.isLoggedIn && (
          <li>
            <a href="/">Admin</a>
          </li>
        )}
        {ctx.isLoggedIn && (
          <li>
            <Button onClick={ctx.onLogOut}>Logout</Button>
          </li>
        )}
      </ul>
    </nav>
  );
};

export default Navigation;
