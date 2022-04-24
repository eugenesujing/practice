import Modal from '../../UI/Modal'
import classes from './OrderForm.module.css'
import CartContext from '../../Storage/CartProvider'
import {useContext, useState, useEffect} from 'react'
import useInput from '../../useInput'
import useHTTP from '../../useHTTP'

function OrderForm(props){
    const [isFormValid, setIsFormValid] = useState(false)

    const ctx = useContext(CartContext)
    const goBackToCart = ()=>{
        props.remove()
        props.backToCart()
    }
    const total = ctx.items.reduce((prev, curr)=>{
          return prev + curr.price * curr.amount
    },0)

    const {value :valueName,
           onEnter:onEnterName,
           onBlur:onBlurName,
           onFocus:onFocusName,
           isValid:isValidName,
           hasError:hasErrorName,
           reset:resetName
    } = useInput((value)=>{return value.trim() !==''})

    const {value :valueAddress,
           onEnter:onEnterAddress,
           onBlur:onBlurAddress,
           onFocus:onFocusAddress,
           isValid:isValidAddress,
           hasError:hasErrorAddress,
           reset:resetAddress
    } = useInput((value)=>{return value.trim() !==''})

    const {value:valuePhone,
           onEnter:onEnterPhone,
           onBlur:onBlurPhone,
           onFocus:onFocusPhone,
           isValid:isValidPhone,
           hasError:hasErrorPhone,
           reset:resetPhone
    } = useInput((value)=>{return value.trim() !==''})

    useEffect(()=>{
            if(isValidAddress && isValidName && isValidPhone){
                setIsFormValid(true)
            }else{
                setIsFormValid(false)
            }
    },[isValidPhone,isValidAddress,isValidName])

    const classNameName = hasErrorName? `${classes['form-control']} ${classes['invalid']}` : classes['form-control']
    const classNameAddress= hasErrorAddress? `${classes['form-control']} ${classes['invalid']}` : classes['form-control']
    const classNamePhone = hasErrorPhone? `${classes['form-control']} ${classes['invalid']}` : classes['form-control']

    const {sendRequest} = useHTTP()
    function onSubmitHandler(e){
        e.preventDefault()
        if(!isFormValid){
            return
        }
        resetPhone()
        resetAddress()
        resetName()
        const postBody = {
            name : valueName,
            address : valueAddress,
            phone : valuePhone
        }
        const {isError} =sendRequest({url:'https://foodorder-ee97b-default-rtdb.firebaseio.com/orders.json',
        method: 'POST',
        headers: {'Content-Type' : 'application/json'},
        body: postBody},()=>{})

        if(!isError){
        props.remove()
        props.onConfirmShow()}

    }
    return (<Modal>
    <form onSubmit={onSubmitHandler}>
        <div className = {classes['control-group']}>
            <div className = {classNameName}>
                <label htmlFor='name'>Your Name</label>
                <input id = 'name'  type ='text' value = {valueName} onChange={onEnterName} onBlur={onBlurName} onFocus={onFocusName}/>
                {hasErrorName && <p className = {classes['error-text']}>Invalid Name!</p>}
            </div>
            <div className = {classNameAddress}>
                <label htmlFor='address'>Your Address</label>
                <input id = 'address' type ='text' value = {valueAddress} onChange={onEnterAddress} onBlur={onBlurAddress} onFocus={onFocusAddress}/>
                {hasErrorAddress && <p className = {classes['error-text']}>Invalid Address!</p>}
            </div>
           <div className = {classNamePhone}>
                <label htmlFor='phone'>Your Phone</label>
                <input id = 'phone' type ='text' value = {valuePhone} onChange={onEnterPhone} onBlur={onBlurPhone} onFocus={onFocusPhone}/>
                {hasErrorPhone && <p className = {classes['error-text']}>Invalid Phone!</p>}
            </div>
        </div>
        <div className = {classes.totals}>
            <h3>Total Amount</h3>
            <h3>${total.toFixed(2)}</h3>
        </div>
        <div className = {classes['form-actions']}>
            <button onClick = {props.remove}>Close</button>
            <button onClick = {goBackToCart}>Back</button>
            <button type = 'submit' disabled={!isFormValid} className = {classes['button--alt']}>Place Order</button>
        </div>
    </form>
    </Modal>)
}

export default OrderForm