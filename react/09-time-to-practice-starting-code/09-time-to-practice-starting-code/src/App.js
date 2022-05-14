import {Route, Switch, Redirect} from 'react-router-dom'
import AllQuotes from './page/AllQuotes'
import Layout from './components/layout/Layout'
import NewQuote from './page/NewQuote'
import QuoteDetails from './page/QuoteDetails'

//version 6, order and key 'exact' does not matter anymore as it will always find the most matching Route
//<Routes>
    //<Route path='/welcome' element={<Welcome/>}/> if path='/welcome/*' means anything path with it
    //<Route path='/quote-details/:quoteId' element={<QuoteDetails/>}/>
//</Routes>
//NavLink activeClassName also not valid in version 6
//<NavLink className = {(navData)=> navData.isActive ? classes.active : ''}>

//Redirect is replaced by Navigate
//<Navigate to/replace='/welcome'>

//<Route> must be placed between <Routes>
//nested Route doesn't need to provide the whole path but only the extra part, relative path
//e.g. path='new-user' instead of path='/welcome/new-user'

//<Outlet/> to indicate there the nested Route should be

//useHistory is also replaced by useNavigate
//const navigate = useNavigate()
//navigate('/welcome',{replace:true)
//navigate(-1),to the previous one, 1 to the next one, -2...2..

function App() {

  return (
    <div>
    <Layout>
    <Switch>
        <Route path='/' exact>
            <Redirect to='/quotes'/>
        </Route>
        <Route path='/quotes'>
            <AllQuotes/>
        </Route>
        <Route path='/add-quotes'>
            <NewQuote onAddQuote/>
        </Route>
        <Route path='/quote-details/:quoteId'>
            <QuoteDetails/>
        </Route>
    </Switch>
    </Layout>
    </div>
  );
}

export default App;
