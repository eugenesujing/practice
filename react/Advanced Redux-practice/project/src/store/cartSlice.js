import {createSlice} from '@reduxjs/toolkit'
import {toggleActions} from './toggleSlice'

const initialState = {items:[], totalQuantity: 0, totalPrice: 0}

const cartSlice = createSlice({
    name: 'cart',
    initialState,
    reducers:{
        replaceCart(state,actions){
            state.items = actions.payload.items || []
            state.totalQuantity = actions.payload.totalQuantity
            state.totalPrice = actions.payload.totalPrice
        },
        addItem(state,actions){
            const id = actions.payload.id
            const currentItem = state.items.find(item=> item.id===id)
            if(!currentItem){
                const newItem = {...actions.payload, totalPrice: actions.payload.price, quantity :1}
                state.items.push(newItem)
            }else{
                currentItem.quantity++
                currentItem.totalPrice = currentItem.totalPrice + currentItem.price
            }
            state.totalQuantity++
            state.totalPrice = state.totalPrice + actions.payload.price
        },
        reduceItem(state,actions){
            const id = actions.payload.id
            const currentItem = state.items.find(item=> item.id===id)
            if(currentItem.quantity ===1){
                state.items = state.items.filter(item=> item.id!==id)
            }else{
                currentItem.quantity--
                currentItem.totalPrice = currentItem.totalPrice - currentItem.price

            }
            state.totalQuantity--
            state.totalPrice = state.totalPrice - actions.payload.price
        }
    }
})

export default cartSlice.reducer

export const cartActions = cartSlice.actions

export function getDataAction(){
    return  (dispatch)=>{
            async function getData(){
                const response = await fetch('https://foodorder-ee97b-default-rtdb.firebaseio.com/items.json')

                if(!response.ok){
                    throw new Error('Getting data has failed!')
                }

                const data = await response.json()

                dispatch(cartActions.replaceCart(data))
            }

            getData().catch(error=>{
                dispatch(toggleActions({
                    status:'error',
                    title:'Error',
                    message:'Getting data has failed'
                }))
            })

    }
}