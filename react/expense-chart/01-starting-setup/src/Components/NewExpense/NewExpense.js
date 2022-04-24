import './NewExpense.css'
import Card from '../UI/Card'
import AddNewExpense from './AddNewExpense'


function NewExpense (props){
    function onSaveHandler (enteredData){
        const data = {
        ...enteredData,
        id : Math.random().toString()
        }
        props.onNewExpense(data)
    }


    return (
        <Card className = 'new-expense'>
            <AddNewExpense onSaveHandler = {onSaveHandler}/>
        </Card>
    )

}

export default NewExpense