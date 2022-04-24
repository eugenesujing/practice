import React, {useImperativeHandle, useRef} from 'react'
import classes from './Input.module.css'

//because React components cannot use ref directly, it can only
//call forwardRef() to forward this ref and useImperativeHandle() to bind the properties
const Input = React.forwardRef((props,ref)=>{
    const inputRef = useRef()

    const activate = ()=>{
        inputRef.current.focus()
    }

    useImperativeHandle(ref,()=>{

    return {
        focus: activate
    }})

    return (
            <div
              className={`${classes.control} ${
                props.validity === false ? classes.invalid : ''
              }`}
            >
              <label htmlFor={props.id}>{props.label}</label>
              <input
                ref = {inputRef}
                type={props.type}
                id={props.id}
                value={props.value}
                onChange={props.onChange}
                onBlur={props.onBlur}
              />
            </div>)
})

export default Input