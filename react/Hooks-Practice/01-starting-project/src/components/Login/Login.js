//useReducer() :const [state, dispatch] = useReducer(reducer, initialState)
//accepts 2 argument: the reducer function and the initial state.
//Also, the reducer returns an array of 2 items: the current state and the dispatch function.

//When you'd like to update the state, simply call dispatch(action) with the appropriate
//action object. The action object is then forwarded to the reducer() function that updates
//the state. If the state has been updated by the reducer, then the component re-renders,
//and [state, ...] = useReducer(...) hook returns the new state value.


import React, { useState, useEffect } from 'react';

import Card from '../UI/Card/Card';
import classes from './Login.module.css';
import Button from '../UI/Button/Button';

const Login = (props) => {
  const [enteredEmail, setEnteredEmail] = useState('');
  const [emailIsValid, setEmailIsValid] = useState();
  const [enteredPassword, setEnteredPassword] = useState('');
  const [passwordIsValid, setPasswordIsValid] = useState();
  const [formIsValid, setFormIsValid] = useState(false);


//it will only be executed when any of the dependencies changed during last cycle
  useEffect(()=>{
        const timer = setTimeout(()=>{
            setFormIsValid(
                enteredEmail.includes('@') && enteredPassword.trim().length > 6)

        },1500)
        //this clean-up function will only run before next useEffect() and when this component is removed
        return ()=>{ clearTimeout(timer)}
  },[enteredEmail,enteredPassword])

  const emailChangeHandler = (event) => {
    setEnteredEmail(event.target.value);

  };

  const passwordChangeHandler = (event) => {
    setEnteredPassword(event.target.value);
  };

  const validateEmailHandler = () => {
    setEmailIsValid(enteredEmail.includes('@'));
  };

  const validatePasswordHandler = () => {
    setPasswordIsValid(enteredPassword.trim().length > 6);
  };

  const submitHandler = (event) => {
    event.preventDefault();
    props.onLogin(enteredEmail, enteredPassword);
  };

  return (
    <Card className={classes.login}>
      <form onSubmit={submitHandler}>
        <div
          className={`${classes.control} ${
            emailIsValid === false ? classes.invalid : ''
          }`}
        >
          <label htmlFor="email">E-Mail</label>
          <input
            type="email"
            id="email"
            value={enteredEmail}
            onChange={emailChangeHandler}
            onBlur={validateEmailHandler}
          />
        </div>
        <div
          className={`${classes.control} ${
            passwordIsValid === false ? classes.invalid : ''
          }`}
        >
          <label htmlFor="password">Password</label>
          <input
            type="password"
            id="password"
            value={enteredPassword}
            onChange={passwordChangeHandler}
            onBlur={validatePasswordHandler}
          />
        </div>
        <div className={classes.actions}>
          <Button type="submit" className={classes.btn} disabled={!formIsValid}>
            Login
          </Button>
        </div>
      </form>
    </Card>
  );
};

export default Login;
