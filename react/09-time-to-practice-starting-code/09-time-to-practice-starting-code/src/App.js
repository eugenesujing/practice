import {Route, Link, Switch, Redirect,useParams, useHistory} from 'react-router-dom'
import AllQuotes from './page/AllQuotes'
import Layout from './components/layout/Layout'
import NoQuotes from './page/NoQuotes'
import NewQuote from './page/NewQuote'
import QuoteDetails from './page/QuoteDetails'

const DUMMY_QUOTES = [
{
id: 'q1',
author: 'jing',
text: 'Feel it, Love it.'
},
{
id: 'q2',
author: 'ken',
text: 'Ahhh.'
}
]

function App() {
    let quoteContent = <AllQuotes quotes = {DUMMY_QUOTES}/>
    if(DUMMY_QUOTES.length === 0){
        quoteContent = <NoQuotes />
    }
    const history = useHistory()
    function onAddHandler(newQuote){
        DUMMY_QUOTES.push({id:`q${DUMMY_QUOTES.length+1}`,author:newQuote.author, text: newQuote.text})

        history.push('/quotes')
    }

  return (
    <div>
    <Layout>
    <Switch>
        <Route path='/' exact>
            <Redirect to='/quotes'/>
        </Route>
        <Route path='/quotes'>
            {quoteContent}
        </Route>
        <Route path='/add-quotes'>
            <NewQuote onAddQuote={onAddHandler}/>
        </Route>
        <Route path='/quote-details/:quoteId'>
            <QuoteDetails quotes = {DUMMY_QUOTES}/>
        </Route>
    </Switch>
    </Layout>
    </div>
  );
}

export default App;
