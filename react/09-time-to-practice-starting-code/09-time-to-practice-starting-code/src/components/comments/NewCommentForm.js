import { useRef,useEffect }from 'react';

import classes from './NewCommentForm.module.css';
import useHttp from '../../hooks/hooks/use-http'
import {addComment} from '../../lib/lib/api'
import LoadingSpinner from '../../components/UI/LoadingSpinner'


const NewCommentForm = (props) => {

  const commentTextRef = useRef();
  const {sendRequest,status,error} = useHttp(addComment)

  const submitFormHandler = (event) => {
    event.preventDefault();

    // optional: Could validate here

    // send comment to server
    sendRequest({quoteId: props.quoteId, commentData: {text: commentTextRef.current.value}})
  };

  useEffect(()=>{
      if(status ==='completed' && !error){
          props.onAdd()
      }
  },[status,error,props])

  if(status ==='pending'){
        return <div className = 'centered'><LoadingSpinner /></div>
  }else if(error){
        return <div className = 'centered focus'><p>{error}</p></div>
  }



  return (
    <form className={classes.form} onSubmit={submitFormHandler}>
      <div className={classes.control} onSubmit={submitFormHandler}>
        <label htmlFor='comment'>Your Comment</label>
        <textarea id='comment' rows='5' ref={commentTextRef}></textarea>
      </div>
      <div className={classes.actions}>
        <button className='btn'>Add Comment</button>
      </div>
    </form>
  );
};

export default NewCommentForm;
