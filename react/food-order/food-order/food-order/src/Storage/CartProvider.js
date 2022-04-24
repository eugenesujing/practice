import React, {useReducer} from 'react';

const CartContext = React.createContext({
    items : [],
    onAdd: (item)=>{},
    onReduce: (item)=>{}
})

function cartReducer(state,actions){
    if(actions.type === 'ADD'){
          const index = state.findIndex((item)=>{return item.name === actions.val.name})
          if(index === -1){
              return state.concat(actions.val)
          }else{
              const currItems = [...state]
              const newItem = {...state[index], amount : state[index].amount + actions.val.amount}
              currItems[index] = newItem
              return currItems
          }
    }
    else if(actions.type === 'REDUCE'){
        const index = state.findIndex((item)=>{return item.name ===actions.val.name})
        const currItems = [...state]
        if(state[index].amount <= actions.val.amount){
            return state.filter((item)=>{return item.name !== actions.val.name})
        }else{
            const newItem = {...state[index], amount : state[index].amount - actions.val.amount}
            currItems[index] = newItem
            return currItems
        }
    }

}

export function CartProvider(props){
    const [cart,dispatchCart] = useReducer(cartReducer,[])


    const onAddHandler= (order)=>{
        dispatchCart({type:'ADD', val:order})
    }

    const onReduceHandler = (order)=>{
        dispatchCart({type:'REDUCE', val:order})
    }





    return <CartContext.Provider value = { {items : cart, onAdd : onAddHandler, onReduce :onReduceHandler}}>
    {props.children}
    </CartContext.Provider>
}

export default CartContext