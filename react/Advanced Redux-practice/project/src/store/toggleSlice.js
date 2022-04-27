import {createSlice} from '@reduxjs/toolkit'

const initialState = {show: false, error: {}}

const toggleSlice = createSlice({
    name: 'toggle',
    initialState,
    reducers:{
        toggle(state){
            state.show = !state.show
        },
        setError(state,actions){
            state.error = actions.payload
        }
    }
})

export default toggleSlice.reducer

export const toggleActions = toggleSlice.actions