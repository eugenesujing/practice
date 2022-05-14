import QuoteList from '../components/quotes/QuoteList'
import useHttp from '../hooks/hooks/use-http'
import {getAllQuotes} from '../lib/lib/api'
import {useEffect} from 'react'
import NoQuotes from './NoQuotes'
import LoadingSpinner from '../components/UI/LoadingSpinner'

function AllQuotes (props){
    //const [allQuotes,setAllQuotes] = useState([])
    const {sendRequest, data, status, error} = useHttp(getAllQuotes,true)
    //console.log(allQuotes,status,'initial')
    useEffect(()=>{
    async function send(){
        await sendRequest()
    }
    send()

    },[sendRequest])

    if(status ==='completed' && error ===null && data && data.length!==0){
        return <div><QuoteList quotes={data}/></div>
    }else if(status ==='pending'){
        return <div className = 'centered'><LoadingSpinner /></div>
    }else if(error){
        return <div className = 'centered focus'><p>{error}</p></div>
    }else{
        return <NoQuotes/>
    }

}

export default AllQuotes