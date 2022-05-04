import QuoteList from '../components/quotes/QuoteList'

function AllQuotes (props){
    return<div>
        <QuoteList quotes={props.quotes}/>
    </div>
}

export default AllQuotes