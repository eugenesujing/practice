import React, {useEffect, useState} from 'react';

const AuthContext = React.createContext({
    isLoggedIn: false,
    onLogOut: ()=>{},
    onLogIn: ()=>{},
})

export function AuthProvider(props){
      const [isLoggedIn, setIsLoggedIn] = useState(false);


      useEffect(()=>{
          const localStoredLoggedIn = localStorage.getItem('isLoggedIn')
            if(localStoredLoggedIn === 'true'){
              setIsLoggedIn(true);
            }
            //leave dependency as empty to make this function run only once
      },[])


      const loginHandler = (email, password) => {
        // We should of course check email and password
        // But it's just a dummy/ demo anyways
        //use the localStorage to help us maintain the login status
        localStorage.setItem('isLoggedIn', 'true');
        setIsLoggedIn(true);
      };

      const logoutHandler = () => {
        localStorage.removeItem('isLoggedIn')
        setIsLoggedIn(false);
      };

    //this value will be passed down to all components down below
    //and they can use useContext() to get this value
    return <AuthContext.Provider value = {{
        isLoggedIn : isLoggedIn,
        onLogOut : logoutHandler,
        onLogIn : loginHandler,
    }}>
    {props.children}
    </AuthContext.Provider>
}

export default AuthContext