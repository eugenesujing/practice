import {createSlice} from '@reduxjs/toolkit'

const initialState = {items:[], totalQuantity: 0, totalPrice: 0}

const cartSlice = createSlice({
    name: 'cart',
    initialState,
    reducers:{
        replaceItem(state,actions){
            state.items = actions.payload
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
            state.totalPrice = state.totalPrice = actions.payload.price
        }
    }
})

export default cartSlice.reducer

export const cartActions = cartSlice.actions