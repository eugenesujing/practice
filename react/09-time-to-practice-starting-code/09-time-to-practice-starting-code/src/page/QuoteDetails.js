import HighlightedQuote from '../components/quotes/HighlightedQuote'
import {useParams, Link, Route, useLocation, useRouteMatch} from 'react-router-dom'
import NoQuotes from './NoQuotes'
import Comments from '../components/comments/Comments'
import useHttp from '../hooks/hooks/use-http'
import {getSingleQuote} from '../lib/lib/api'
import {useEffect} from 'react'
import LoadingSpinner from '../components/UI/LoadingSpinner'



function QuoteDetails(){
    const param = useParams()
    const match = useRouteMatch()
    const location = useLocation()
    const {quoteId} = param

    const {sendRequest,data, status, error} = useHttp(getSingleQuote,true)

    useEffect(()=>{
        sendRequest(quoteId)
    },[sendRequest,quoteId ])

    if(status === 'pending'){
        return <div className = 'centered'><LoadingSpinner /></div>
    }else if(error){
        return <div className = 'centered focus'><p>{error}</p></div>
    }


    const foundQuote = data
    if(!foundQuote.author){
        return <NoQuotes />
    }

    const showComments = location.pathname===`${match.url}/comments`
    let Button = <Link className='btn--flat' to={`${match.url}/comments`}>Load Comments</Link>
    if(showComments){
        Button = <Link className='btn--flat' to={`${match.url}`}>Hide Comments</Link>
    }


    return <div>
        <HighlightedQuote quote={foundQuote}/>
        <div className = 'centered'>
            {Button}
        </div>
        <Route path={`${match.path}/comments`}>
           <Comments quoteId = {quoteId}/>
        </Route>

    </div>
}

export default QuoteDetails