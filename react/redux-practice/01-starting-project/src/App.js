import Counter from './components/Counter';
import Auth from './components/Auth';
import Header from './components/Header';
import UserProfile from './components/UserProfile'
import {Fragment} from 'react'


import {useSelector, useDispatch} from 'react-redux'

function App() {
    const loggedIn = useSelector(state => state.auth.loggedIn)
    const dispatch = useDispatch()

  return (
    <Fragment>
        <Header/>
        {loggedIn ? <UserProfile/>:<Auth/>}
        <Counter />
    </Fragment>
  );
}

export default App;
