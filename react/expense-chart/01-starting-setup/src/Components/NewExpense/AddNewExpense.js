import {useState} from 'react'
import ExpenseForm from './ExpenseForm'

function AddNewExpense(props){
    const [display, setDisplay] = useState(0)

    const onClickHandler = () => {
        setDisplay(1)
    }

    const onCancelHandler = () => {
        setDisplay(0)
    }

    if(display === 1){
        return <ExpenseForm onSaveHandler = {props.onSaveHandler} onCancelHandler = {onCancelHandler}/>
    }

    return <button onClick ={onClickHandler}>Add New Expense</button>
}

export default AddNewExpense