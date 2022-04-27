import Cart from './components/Cart/Cart';
import Layout from './components/Layout/Layout';
import Products from './components/Shop/Products';
import {useSelector, useDispatch} from 'react-redux'
import {useEffect} from 'react'

import {toggleActions} from './store/toggleSlice'
import {getDataAction} from './store/cartSlice'

let initial = true

function App() {

  const dispatch = useDispatch()
  const toggle = useSelector(store=>store.toggle.show)
  const cart = useSelector(store=>store.cart)

  useEffect(()=>{
    dispatch(getDataAction())
  },[dispatch])

  useEffect(()=>{
      async function sendData(){

       const response = await fetch('https://foodorder-ee97b-default-rtdb.firebaseio.com/items.json',{
           method: 'PUT',
           body:JSON.stringify(cart)
       })
       if(!response.ok){
          throw new Error('Sending data has failed!')
       }
    }

    if(initial){
        initial=false
        return
    }
    sendData().catch(error=>{
        dispatch(toggleActions.setError({
            status:'error',
            title:'Error',
            message: 'Sending data has failed!'
        }))
    }
    )
  },[cart,dispatch])



  return (
    <Layout>
      {toggle && <Cart />}
      <Products />
    </Layout>
  );
}

export default App;
