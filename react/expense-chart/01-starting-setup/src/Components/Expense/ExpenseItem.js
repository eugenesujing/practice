import './ExpenseItem.css'
import ExpenseDate from './ExpenseDate'
import Card from '../UI/Card'

function ExpenseItem (props){

    //everything between <Card> and </Card> will not be shown expect props.children is used
    return (
    <li>
        <Card className = "expense-item">
            <ExpenseDate date = {props.date} />
            <div className = "expense-item__description">
                <h2>{props.title}</h2>
                <div className = "expense-item__price">${props.amount}</div>
            </div>
        </Card>
    </li>
    )
}

export default ExpenseItem