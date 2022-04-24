import {useState} from 'react'
import './ExpenseForm.css'

function ExpenseForm (props){
    const [enteredTitle, setTitle ]= useState('')
    const [enteredAmount, setAmount ]= useState('')
    const [enteredDate, setDate ]= useState('')

    const onSubmitHandler = (e)=> {
        e.preventDefault()
        const data = {
        title : enteredTitle,
        // '+' before a string will convert that string to a number
        amount : +enteredAmount,
        date : new Date(enteredDate)
        }
        props.onSaveHandler(data)
        props.onCancelHandler()
        setTitle('')
        setAmount('')
        setDate('')
    }

    const onChangeHandlerTitle = (e) => {
        setTitle(e.target.value)
    }

    const onChangeHandlerAmount = (e) => {
        setAmount(e.target.value)
    }

    const onChangeHandlerDate = (e) => {
        setDate(e.target.value)
    }



    return (
    <form onSubmit = {onSubmitHandler}>
        <div className = 'new-expense__controls'>
            <div className = 'new-expense__control'>
                <label>Title</label>
                <input type = 'text' value = {enteredTitle} onChange = {onChangeHandlerTitle}/>
            </div>

            <div className = 'new-expense__control'>
                <label>Amount</label>
                <input type = 'number' value = {enteredAmount} onChange = {onChangeHandlerAmount}/>
            </div>

            <div className = 'new-expense__control'>
                <label>Date</label>
                <input type = 'date' value = {enteredDate} onChange = {onChangeHandlerDate}/>
            </div>
        </div>
        <div className = 'new-expense__actions'>
            <button onClick = {props.onCancelHandler}>Cancel</button>
            <button type = 'submit'>Add Expense</button>
        </div>

    </form>
    )
}

export default ExpenseForm