import {useState, useCallback} from 'react'

function useHTTP(){
    const [isLoading,setIsLoading] = useState(false)
    const [isError, setIsError] = useState(null)

    const sendRequest= useCallback(async (request, appData)=>{
    setIsLoading(true)
    setIsError(null)
        try{
            const response = await fetch(request.url
            ,{
            method : request.method ? request.method : 'GET',
            header : request.header ? request.header : {},
            body : request.body ? JSON.stringify(request.body) : null
            })
            if(!response.ok){
                throw new Error('Request Failed!')
            }

            const data = await response.json()
            console.log(data)
            appData(data)

        }catch(err){
            setIsError(err.message || 'Something went wrong')

        }
        setIsLoading(false)
    },[])



    return {isError,isLoading, sendRequest}


}

export default useHTTP