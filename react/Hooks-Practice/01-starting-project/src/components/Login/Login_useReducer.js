//useReducer() :const [state, dispatch] = useReducer(reducer, initialState)
//accepts 2 argument: the reducer function and the initial state.
//Also, the reducer returns an array of 2 items: the current state and the dispatch function.

//When you'd like to update the state, simply call dispatch(action) with the appropriate
//action object. The action object is then forwarded to the reducer() function that updates
//the state. If the state has been updated by the reducer, then the component re-renders,
//and [state, ...] = useReducer(...) hook returns the new state value.


import React, { useState, useEffect, useReducer, useRef } from 'react';

import Card from '../UI/Card/Card';
import classes from './Login.module.css';
import Button from '../UI/Button/Button';
import Input from '../UI/Input/Input';

    function emailReducer(state, actions){
        if(actions.type === 'USER_INPUT'){
            return {value: actions.val, validity: actions.val.includes('@')}
        }
        else if (actions.type === 'INPUT_BLUR'){
            return {value: state.value, validity: state.value.includes('@')}
        }
    }

    function passwordReducer(state, actions){
        if(actions.type === 'USER_INPUT'){
            return {value: actions.val, validity: actions.val.trim().length > 6}
        }
        else if (actions.type === 'INPUT_BLUR'){
            return {value: state.value, validity: state.value.trim().length > 6}
        }
    }

const Login = (props) => {
//  const [enteredEmail, setEnteredEmail] = useState('');
//  const [emailIsValid, setEmailIsValid] = useState();
//  const [enteredPassword, setEnteredPassword] = useState('');
//  const [passwordIsValid, setPasswordIsValid] = useState();
  const [formIsValid, setFormIsValid] = useState(false);

//use useReducer to deal with complex states or several states that are related
  const [email, dispatchEmail] = useReducer(emailReducer, {value:'', validity:null })
  const [password, dispatchPassword] = useReducer(passwordReducer, {value:'', validity:null })

  const refEmail = useRef()
  const refPassword = useRef()
//it will only be executed when any of the dependencies changed during last cycle
  useEffect(()=>{
        console.log('Checking Validity')
        const timer = setTimeout(()=>{

            setFormIsValid(
                email.validity && password.validity)

        },1000)
        //this clean-up function will only run before next useEffect() and when this component is removed
        return ()=>{ clearTimeout(timer)}
  },[email.validity,password.validity])

  const emailChangeHandler = (event) => {
    dispatchEmail({type: 'USER_INPUT', val: event.target.value})

  };

  const passwordChangeHandler = (event) => {
    dispatchPassword({type: 'USER_INPUT', val: event.target.value})
  };

  const validateEmailHandler = () => {
    dispatchEmail({type: 'INPUT_BLUR'})
  };

  const validatePasswordHandler = () => {
    dispatchPassword({type: 'INPUT_BLUR'})
  };

  const submitHandler = (event) => {
    event.preventDefault();
    //if there's invalid input when submit,
    //the first invalid input will be focused
    if(formIsValid){
        props.onLogin(email.value, password.value);
    }else if (!email.validity){
        refEmail.current.focus()
    }else{
        refPassword.current.focus()
    }
  };

  return (
    <Card className={classes.login}>
      <form onSubmit={submitHandler}>
        <Input validity = {email.validity}
        label = 'Email' id = 'email' value = {email.val} type = 'email'
        onChange = {emailChangeHandler}
        onBlur = {validateEmailHandler}
        ref = {refEmail}/>
        <Input validity = {password.validity}
         label = 'Password' id = 'password' value = {password.val} type = 'password'
         onChange = {passwordChangeHandler}
         onBlur = {validatePasswordHandler}
         ref = {refPassword}/>
        <div className={classes.actions}>
          <Button type="submit" className={classes.btn}>
            Login
          </Button>
        </div>
      </form>
    </Card>
  );
};

export default Login;
