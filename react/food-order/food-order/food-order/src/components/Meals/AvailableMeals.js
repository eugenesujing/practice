import React, {useEffect, useState} from 'react'
import classes from './AvailableMeals.module.css'
import Card from '../../UI/Card'
import MealItem from './MealItem'
import useHTTP from '../../useHTTP'


function AvailableMeals(props){
    const [mealsData, setMealsData] = useState([])
    function loadDate(data){
        const tempData = []
        for (const key in data){
            tempData.push({
                id:key,
                name: data[key].name,
                description: data[key].description,
                price : data[key].price
            })
        }
        setMealsData(tempData)
    }

    const {
    isLoading,
    isError,
    sendRequest
    } =  useHTTP()

    useEffect(()=>{
       sendRequest({url:'https://foodorder-ee97b-default-rtdb.firebaseio.com/meals.json'},loadDate)
    }
    ,[sendRequest])

    let content = null
    if(isLoading){
        content = <p>Loading...</p>
    }
    if(isError){
        content = <p>{isError}</p>
    }else{
        content = mealsData.map((meal) => <MealItem meal = {meal} key = {meal.id}>{meal.name}</MealItem>)

    }

   return <Card className = {classes['meals']}>
        <ul>
            {content}
        </ul>
    </Card>
}

export default React.memo(AvailableMeals)