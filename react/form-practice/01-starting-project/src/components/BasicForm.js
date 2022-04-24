import useInput from './useInput'

//use the custom hook to manage the states for all three inputs
const BasicForm = (props) => {
    const {
        enteredValue : enteredFirstName,
        isValid : isFirstNameValid,
        enteredValueInValid : enteredFirstNameInValid,
        onFocusHandler : onFocusHandlerFirstName,
        onBlurHandler: onBlurHandlerFirstName,
        onChangeHandler: onChangeHandlerFirstName,
        reset: resetFirstName
    } = useInput((value)=>{return value.trim() !==''})

    const {
        enteredValue : enteredLastName,
        isValid : isLastNameValid,
        enteredValueInValid : enteredLastNameInValid,
        onFocusHandler : onFocusHandlerLastName,
        onBlurHandler: onBlurHandlerLastName,
        onChangeHandler: onChangeHandlerLastName,
        reset: resetLastName
    } = useInput((value)=>{return value.trim() !==''})

     const {
         enteredValue : enteredEmail,
         isValid : isEmailValid,
         enteredValueInValid : enteredEmailInValid,
         onFocusHandler : onFocusHandlerEmail,
         onBlurHandler: onBlurHandlerEmail,
         onChangeHandler: onChangeHandlerEmail,
         reset : resetEmail
     } = useInput((value)=>{return value.trim().includes('@')})

    const classFirstName = enteredFirstNameInValid ? 'form-control invalid' : 'form-control'
    const classLastName = enteredLastNameInValid ? 'form-control invalid' : 'form-control'
    const classEmail = enteredEmailInValid ? 'form-control invalid' : 'form-control'

    let isFormValid = false
    if(isEmailValid && isFirstNameValid && isLastNameValid){
        isFormValid = true
    }


    function onSubmitHandler(e){
        e.preventDefault()
        if(!isFormValid){
            return
        }
        resetFirstName()
        resetLastName()
        resetEmail()
    }
  return (
    <form onSubmit = {onSubmitHandler}>
      <div className='control-group'>
        <div className={classFirstName}>
          <label htmlFor='name'>First Name</label>
          <input type='text' id='name' value = {enteredFirstName} onChange = {onChangeHandlerFirstName} onBlur={onBlurHandlerFirstName} onFocus={onFocusHandlerFirstName}/>
            {enteredFirstNameInValid && <p className='error-text'>Invalid First Name!</p>}
        </div>
        <div className={classLastName}>
          <label htmlFor='name'>Last Name</label>
          <input type='text' id='name' value = {enteredLastName} onChange = {onChangeHandlerLastName} onBlur={onBlurHandlerLastName} onFocus={onFocusHandlerLastName}/>
        {enteredLastNameInValid && <p className='error-text'>Invalid Last Name!</p>}
        </div>
      </div>
      <div className={classEmail}>
        <label htmlFor='name'>E-Mail Address</label>
        <input type='text' id='name' value = {enteredEmail} onChange = {onChangeHandlerEmail} onBlur={onBlurHandlerEmail} onFocus={onFocusHandlerEmail}/>
      {enteredEmailInValid && <p className='error-text'>Invalid Email!</p>}
      </div>
      <div className='form-actions'>
        <button type = 'submit' disabled={!isFormValid}>Submit</button>
      </div>
    </form>
  );
};

export default BasicForm;
