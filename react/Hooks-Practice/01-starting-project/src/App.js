import React, { useContext } from 'react';

import Login from './components/Login/Login_useReducer';
import Home from './components/Home/Home';
import MainHeader from './components/MainHeader/MainHeader';
import AuthContext from './components/Wrapper/AuthProvider'

function App() {
  const ctx = useContext(AuthContext)

  return (
    <React.Fragment>
      <MainHeader/>
      <main>
        {!ctx.isLoggedIn && <Login onLogin={ctx.onLogIn} />}
        {ctx.isLoggedIn && <Home onLogout={ctx.onLogOut} />}
      </main>
    </React.Fragment>
  );
}

export default App;
