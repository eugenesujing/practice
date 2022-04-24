import {useState} from 'react'

function useInput(validate){
    const [isTouched,setIsTouched] = useState(false)
    const [value, setValue] = useState('')

    const isValid = validate(value);
    const hasError = isTouched && !isValid;

    const onEnter=(e)=>{
        setValue(e.target.value)
    }

    const onBlur=()=>{
        setIsTouched(true)
    }

    const onFocus=()=>{
        setIsTouched(false)
    }

    const reset=()=>{
        setValue('')
        setIsTouched(false)
    }

    return {
        value,
        onEnter,
        onBlur,
        onFocus,
        isValid,
        hasError,
        reset
    }

}

export default useInput