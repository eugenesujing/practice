import './Chart.css'
import ChartBar from './ChartBar'

function Chart (props){
    const valueArray = props.dataPoints.map(dataPoint => dataPoint.value)
    //max() only accepts a list of arguments so we use '...' to extract the values out from an array
    const maxValue = Math.max(...valueArray)

    return <div className = 'chart'>
        {props.dataPoints.map(dataPoint =>
        <ChartBar label = {dataPoint.label}
        value = {dataPoint.value}
        max = {maxValue}
        key = {dataPoint.label}
        />)}
    </div>

}

export default Chart