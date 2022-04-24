import './ExpenseList.css'
import ExpenseItem from './ExpenseItem'

function ExpenseList (props){
    if(props.items.length === 0){
        return <h2 className = 'expenses-list__fallback'> No Expense Found.</h2>
    }
    //react will display components side by side for each element inside an array of components
    //we need to use 'key' attribute for a list of dynamic components to help react identify different components for the purpose of performance
    return (
    <ul className = 'expenses-list'>
        {props.items.map( filteredExpense =>
            (<ExpenseItem key = {filteredExpense.id}
                     title = {filteredExpense.title}
                     amount = {filteredExpense.amount}
                     date = {filteredExpense.date}/>)
        )}
    </ul>
    )

}

export default ExpenseList