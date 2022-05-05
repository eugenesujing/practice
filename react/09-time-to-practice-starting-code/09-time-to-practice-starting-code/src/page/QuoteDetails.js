import HighlightedQuote from '../components/quotes/HighlightedQuote'
import {useParams} from 'react-router-dom'
import NoQuotes from './NoQuotes'
import Comments from '../components/comments/Comments'
import CommentsList from '../components/comments/CommentsList'

const DUMMY_COMMENTS=[{
id: 'c1',
text: 'Bravo!'
},
{
id: 'c2',
text: 'Awesome!'
}]

function QuoteDetails(props){
    const param = useParams()

    const foundQuote = props.quotes.find((quote)=>{return quote.id ===param.quoteId})
    if(!foundQuote){
        return <NoQuotes />
    }
    return <div>
        <HighlightedQuote quote={foundQuote}/>
        <Comments/>
        <CommentsList comments={DUMMY_COMMENTS}/>
    </div>
}

export default QuoteDetails