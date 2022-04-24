import {Fragment} from 'react'

import CartButton from './CartButton'
import MealSummary from './MealSummary'

import classes from './Header.module.css'
import image from '../../image/meals.jpg'

function Header(props){
    return(<Fragment>
        <div className = {classes.header}>
            <h2>ReactMeals</h2>
            <CartButton onClick = {props.onAdd}/>
        </div>
        <div className = {classes['main-image']}>
            <img src = {image} alt ='meals'></img>
        </div>
        <MealSummary />

    </Fragment>)
}

export default Header