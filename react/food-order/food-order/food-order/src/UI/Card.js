import './Card.css'

function Card (props){
    //use props.children to display contents between brackets
    return (<div className = {'card '+props.className}>{props.children}</div>)
}

export default Card