import {configureStore} from '@reduxjs/toolkit'

import cartReducer from './cartSlice'
import toggleReducer from './toggleSlice'

const store = configureStore({
    reducer:{ cart : cartReducer, toggle: toggleReducer}
})

export default store