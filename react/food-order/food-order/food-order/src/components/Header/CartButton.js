import {useContext, useEffect, useState} from 'react'
import CartIcon from './CartIcon'
import classes from './CartButton.module.css'
import CartContext from '../../Storage/CartProvider'

function CartButton(props){
    const [isBump, setIsBump] = useState(false)
    const ctx = useContext(CartContext)
    const {items} = ctx

    useEffect(()=>{
    console.log("Effect!")
        setIsBump(true)
        const timer = setTimeout(()=>{
        console.log('False')
            setIsBump(false)
        },1500)

        return ()=>{clearTimeout(timer)}
    },[items])

    let totalAmount = 0
    if(items.length > 0){
    totalAmount = items.reduce((prev, curr)=>{
            return prev + curr.amount
        },0)
    }

    return <div className = {`${classes.button} ${isBump && classes.bump}`} onClick = {props.onClick}>
        <span className = {classes.icon}><CartIcon/></span>
        <span > Your Cart</span>
        <span className = {classes.badge}>{totalAmount} </span>
    </div>
}

export default CartButton