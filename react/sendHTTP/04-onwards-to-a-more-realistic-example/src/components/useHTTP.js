import {useState} from 'react'

function useHTTP(request, appData){
    const [isLoading,setIsLoading] = useState(false)
    const [isError, setIsError] = useState(null)

    const async sendRequest(){
    setIsLoading(true)
    setIsError(null)
        try{
            const response = await fetch('https://react-http-6b4a6.firebaseio.com/tasks.json'
            ,request)
            if(!response.ok){
                throw new Error('Request Failed!')
            }

            const data = await response.json()

            appData(data)

        }catch(err){
            setIsError(err.message || 'Something went wrong')

        }
        setIsLoading(false)
    }



    return {isError,isLoading, sendRequest}


}

export default useHTTP