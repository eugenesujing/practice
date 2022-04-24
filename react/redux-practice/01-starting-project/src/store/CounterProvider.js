import {configureStore, createSlice} from '@reduxjs/toolkit'

const initialStateCounter = {counter : 0, counterShow: false}

const counterSlice = createSlice({
    name : 'counter',
    initialState : initialStateCounter,
    reducers:{
        increment(state){
            state.counter++
        },
        decrement(state){
            state.counter --
        },
        increase(state, action){
            state.counter = state.counter + action.payload
        },
        toggleCounter(state){
            state.counterShow = !state.counterShow
        }
    }
})

const initialStateAuth = {loggedIn : false}

const authSlice = createSlice({
    name : 'auth',
    initialState : initialStateAuth,
    reducers: {
        loggedIn(state){
            state.loggedIn = true
        },
        loggedOut(state){
            state.loggedIn = false
        }
    }
})

const store = configureStore({
    reducer:{counter : counterSlice.reducer, auth : authSlice.reducer}
})

export const counterActions = counterSlice.actions
export const authActions = authSlice.actions

export default store