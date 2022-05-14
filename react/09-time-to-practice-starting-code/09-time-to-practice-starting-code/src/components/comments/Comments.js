import { useState ,useCallback} from 'react';

import classes from './Comments.module.css';
import NewCommentForm from './NewCommentForm';
import CommentsList from './CommentsList';
import useHttp from '../../hooks/hooks/use-http'
import {getAllComments} from '../../lib/lib/api'
import {useEffect} from 'react'
import LoadingSpinner from '../../components/UI/LoadingSpinner'

const Comments = (props) => {
  const [isAddingComment, setIsAddingComment] = useState(false);
  const [added,setAdded] = useState(false);
  const {sendRequest,data,status,error} = useHttp(getAllComments)

  useEffect(()=>{
    console.log('grab comments')
    sendRequest(props.quoteId)
  },[sendRequest, props.quoteId,added ])



  let comments

  if(status ==='pending'){
        comments= <div className = 'centered'><LoadingSpinner /></div>
  }else if(error){
        comments= <div className = 'centered focus'><p>{error}</p></div>
  }

  if(!data || data.length===0){
    comments= <div className = 'centered focus'><p>No comments were added yet.</p></div>
  }else{
    comments = <CommentsList comments={data}/>
  }

  const startAddCommentHandler = () => {
    setAdded(false);
    setIsAddingComment(true);
  };

  //because onAddHandler is passed to <NewCommentForm> where it'll be used within useEffect, so this function cannot be re-created
  const onAddHandler= useCallback(()=>{
    setIsAddingComment(false);
    setAdded(true);
  },[setAdded,setIsAddingComment])
  
  return (
    <section className={classes.comments}>
      <h2>User Comments</h2>
      {!isAddingComment && (
        <button className='btn' onClick={startAddCommentHandler}>
          Add a Comment
        </button>
      )}
      {isAddingComment && <NewCommentForm quoteId = {props.quoteId} onAdd={onAddHandler}/>}
      {comments}
    </section>
  );
};

export default Comments;
