import {createSlice} from '@reduxjs/toolkit'

const initialState = {show: false}

const toggleSlice = createSlice({
    name: 'toggle',
    initialState,
    reducers:{
        toggle(state){
            state.show = !state.show
        }
    }
})

export default toggleSlice.reducer

export const toggleActions = toggleSlice.actions