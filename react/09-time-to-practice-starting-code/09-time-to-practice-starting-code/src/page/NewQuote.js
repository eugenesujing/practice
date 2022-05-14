import QuoteForm from '../components/quotes/QuoteForm'
import useHttp from '../hooks/hooks/use-http'
import {addQuote} from '../lib/lib/api'
import {useEffect} from 'react'
import LoadingSpinner from '../components/UI/LoadingSpinner'
import {useHistory} from 'react-router-dom'

function NewQuote (){

    const history = useHistory()
    const {sendRequest, status, error} = useHttp(addQuote)
    function onAddQuoteHandler(newQuote){
      sendRequest({author:newQuote.author, text: newQuote.text})

    }
    useEffect(()=>{
        console.log('useEffect')
        if(status ==='completed' && error ===null){
           history.push('/quotes')
        }
    },[status,error, history])

    if(status ==='pending'){
        return <div className = 'centered'><LoadingSpinner /></div>
    }else if(error){
        return <div className = 'centered focus'><p>{error}</p></div>
    }else{
        return <div>
            <QuoteForm onAddQuote={onAddQuoteHandler}/>
         </div>
    }


}

export default NewQuote