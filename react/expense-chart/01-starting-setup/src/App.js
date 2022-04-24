import {useState} from 'react'
import Expenses from './Components/Expense/Expenses'
import NewExpense from './Components/NewExpense/NewExpense'

    const INITIAL_EXPENSES = [
         {
        id: 'e1',
        title: "Toilet Paper",
        amount: 94.12,
        date: new Date(2020, 7, 14),
        },
        {
           id: 'e2',
           title: "Car Insurance",
           amount: 294.12,
           date: new Date(2021, 8, 14),
       },
        {
           id: 'e3',
           title: "New Desk (Wooden)",
           amount: 394.12,
           date: new Date(2022, 1, 14),
       },
        {
           id: 'e4',
           title: "New TV",
           amount: 354.12,
           date: new Date(2022, 3, 4),
       },
    ];

function App() {
    const [expenses, setExpenses] = useState(INITIAL_EXPENSES)

    const onNewExpense = (newExpense) =>{
        //use prevState function if the new state value depends on the previous state
        setExpenses((prevExpense)=>{
            return [newExpense, ...prevExpense]
        })
    }

  return (
    <div>
      <NewExpense onNewExpense = {onNewExpense}/>
      <Expenses expenses = {expenses}/>

    </div>
  );
}

export default App;
