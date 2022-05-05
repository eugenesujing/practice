import QuoteForm from '../components/quotes/QuoteForm'

function NewQuote (props){
    function onAddQuoteHandler(newQuote){
        props.onAddQuote(newQuote)
    }
    return <div>
        <QuoteForm onAddQuote={onAddQuoteHandler}/>
    </div>
}

export default NewQuote