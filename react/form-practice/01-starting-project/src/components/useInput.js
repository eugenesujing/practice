import {useState} from 'react'

function useInput(validateDate){

    const [enteredValue, setEnteredValue] = useState('')
    const [isTouched, setIsTouched] = useState(false)
    const isValid = validateDate(enteredValue)
    const enteredValueInValid = isTouched && !isValid

    function onChangeHandler(e){
        setEnteredValue(e.target.value)

    }
    function onBlurHandler(e){
        setIsTouched(true)

    }
    function onFocusHandler(e){
        setIsTouched(false)
    }

    function reset(){
        setEnteredValue('')
        setIsTouched(false)
    }

    return {
        enteredValue,
        isValid,
        enteredValueInValid,
        onFocusHandler,
        onBlurHandler,
        onChangeHandler,
        reset
    }
}

export default useInput
