import {useRef} from 'react'

import classes from './MealForm.module.css'

function MealForm(props){
    const inputRef = useRef()
    function onAddHandler(e){
        e.preventDefault()
        props.onAdd(+inputRef.current.value)
    }

    return <form className = {classes.form} onSubmit = {onAddHandler}>
        <div className = {classes.input}>
            <label>Amount</label>
            <input ref = {inputRef} type = 'number' min = '1' max = '5' step = '1' defaultValue = '0'></input>
        </div>
        <button type = 'submit'>+ADD</button>
    </form>
}

export default MealForm