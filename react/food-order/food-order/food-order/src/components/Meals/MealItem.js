import {useContext} from 'react'
import classes from './MealItem.module.css'
import MealForm from './MealForm'
import CartContext from '../../Storage/CartProvider'

function MealItem(props){
    const ctx = useContext(CartContext)
    const {onAdd} = ctx
    function onAddHandler(value){
        onAdd({
            name : props.meal.name,
            price : props.meal.price,
            amount : value
        })
    }

    return <li className = {classes.meal} >
        <div >
            <h3>{props.meal.name}</h3>
            <p className = {classes.description}>{props.meal.description}</p>
            <h3 className = {classes.price}>{`$${props.meal.price.toFixed(2)}`}</h3>
        </div>
        <MealForm  onAdd = {onAddHandler}/>
    </li>
}

export default MealItem