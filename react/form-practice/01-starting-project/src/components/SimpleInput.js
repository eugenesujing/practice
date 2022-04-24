import {useState} from 'react'


const SimpleInput = (props) => {
    const [enteredName, setEnteredName] = useState('')
    const [isNameTouched, setIsNameTouched] = useState(false)
    const [enteredEmail, setEnteredEmail] = useState('')
    const [isEmailTouched, setIsEmailTouched] = useState(false)

    let isFormValid = false;
    const isNameValid = enteredName.trim() !==''
    const enteredNameInValid = isNameTouched && !isNameValid
    const className = enteredNameInValid ? 'form-control invalid' : 'form-control'

    const isEmailValid = enteredEmail.trim().includes('@')
    const enteredEmailInValid = isEmailTouched && !isEmailValid
    const classEmail = enteredEmailInValid ? 'form-control invalid' : 'form-control'

    if(isNameValid && isEmailValid){
        isFormValid = true
    }

    function onSubmitHandler(e){
        e.preventDefault()
        setIsNameTouched(true)
        setIsEmailTouched(true)
        if(!isNameValid){
            return
        }
        setEnteredName('')
        setEnteredEmail('')

        setIsNameTouched(false)
        setIsEmailTouched(false)
    }

    function onChangeHandler(e){
        setEnteredName(e.target.value)

    }
    function onBlurHandler(e){
        setIsNameTouched(true)

    }
    function onFocusHandler(e){
        setIsNameTouched(false)
    }

    function onEmailBlurHandler(){
        setIsEmailTouched(true)
    }

    function onEmailChangeHandler(e){
        setEnteredEmail(e.target.value)
    }

    function onEmailFocusHandler(){
        setIsEmailTouched(false)
    }

  return (
    <form onSubmit = {onSubmitHandler}>
      <div className={className}>
        <label htmlFor='name'>Your Name</label>
        <input onChange = {onChangeHandler} onFocus={onFocusHandler} onBlur={onBlurHandler} type='text' id='name' value={enteredName}/>
        {enteredNameInValid && <p className = 'error-text'>Invalid Input!</p>}
      </div>
      <div className={classEmail}>
        <label htmlFor='email'>Your Email</label>
        <input onChange = {onEmailChangeHandler} onFocus={onEmailFocusHandler} onBlur={onEmailBlurHandler} type='email' id='email' value={enteredEmail}/>
        {enteredEmailInValid && <p className = 'error-text'>Invalid Input!</p>}
      </div>
      <div className="form-actions">
        <button disabled={!isFormValid} type ='submit'>Submit</button>
      </div>
    </form>
  );
};

export default SimpleInput;
