import './ChartBar.css'

function ChartBar (props){
    let valueHeight = '0%'
    if(props.max >0){
        //set the height of the bar as the relative height to the max value
        valueHeight = Math.round((props.value / props.max) * 100) + '%'
    }
    //be careful about the way to set the style within a curly brace
    //e.g. style = {{height : valueHeight, backgroundColor : 'red'}}
    return <div className = 'chart-bar'>
        <div className = 'chart-bar__inner'>
            <div className = 'chart-bar__fill' style = {{height: valueHeight}}></div>
        </div>
        <label className = 'chart-bar__label'>{props.label}</label>
    </div>
}

export default ChartBar