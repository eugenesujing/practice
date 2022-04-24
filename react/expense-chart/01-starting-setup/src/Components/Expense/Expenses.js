import {useState} from 'react'
import ExpenseList from './ExpenseList'
import './Expenses.css'
import ExpenseFilter from './ExpenseFilter'
import Card from'../UI/Card'
import ExpenseChart from '../ExpenseChart/ExpenseChart'

function Expenses(props){
    const [selectValue, setSelectValue] = useState('2022')

    function onSelectHandler(data){
        setSelectValue(data)
    }

    const filteredExpenses = props.expenses.filter( expense => {
        return expense.date.getFullYear().toString() === selectValue})



    return (
        <Card className = 'expenses'>
              <ExpenseFilter value = {selectValue} onSelectHandler = {onSelectHandler}/>
              <ExpenseChart expenses = {filteredExpenses} />
              <ExpenseList items = {filteredExpenses} />
        </Card>
    )
}

export default Expenses