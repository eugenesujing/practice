import {Route, Link, Switch, Redirect,useParams} from 'react-router-dom'
import AllQuotes from './page/AllQuotes'
import Layout from './components/layout/Layout'
import NoQuotes from './page/NoQuotes'
import NewQuote from './page/NewQuote'

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
            <NewQuote/>
        </Route>
    </Switch>
    </Layout>
    </div>
  );
}

export default App;
