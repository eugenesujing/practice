import {useState, Fragment } from 'react';
import {Prompt} from 'react-router-dom';

import Card from '../UI/Card';
import LoadingSpinner from '../UI/LoadingSpinner';
import classes from './QuoteForm.module.css';

const QuoteForm = (props) => {
  const [isTouched,setIsTouched] = useState(false)
  const [enteredData, setEnteredData] = useState({author:'',text:''})

  let validity = enteredData.author.trim()!=='' && enteredData.text.trim()!==''

  function submitFormHandler(event) {
    event.preventDefault();

    // optional: Could validate here
    props.onAddQuote({ author: enteredData.author, text: enteredData.text});

  }

  function onChangeAuthor(e){
    setEnteredData((prev)=>{
        return {...prev, author: e.target.value}
    })
  }

  function onChangeText(e){
    setEnteredData((prev)=>{
        return {...prev, text: e.target.value}
    })
  }

  function onFinishHandler(){
      setIsTouched(false)
  }

  function onFocusHandler(){
    setIsTouched(true)

  }

  return (
  <Fragment>
    <Prompt when ={isTouched} message='Your entered data will lost.'/>
    <Card>
      <form onFocus={onFocusHandler} className={classes.form} onSubmit={submitFormHandler}>
        {props.isLoading && (
          <div className={classes.loading}>
            <LoadingSpinner />
          </div>
        )}

        <div className={classes.control}>
          <label htmlFor='author'>Author</label>
          <input type='text' id='author' onChange={onChangeAuthor}/>
        </div>
        <div className={classes.control}>
          <label htmlFor='text'>Text</label>
          <textarea id='text' rows='5' onChange={onChangeText}></textarea>
        </div>
        <div className={classes.actions}>
          <button disabled={!validity} onClick={onFinishHandler} className='btn'>Add Quote</button>
        </div>
      </form>
    </Card>
  </Fragment>
  );
};

export default QuoteForm;
