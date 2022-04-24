import ReactDOM from 'react-dom'

import classes from './Modal.module.css'

const Backdrop = (props)=>{
    return <div onClick={props.onClick} className = {classes.backdrop}></div>
}

const Overlay = (props)=>{
    return <div className = {classes.modal}>{props.children}</div>
}



function Modal(props){

    return<div>
        {ReactDOM.createPortal(<Backdrop onClick = {props.onRemove}/>,document.getElementById('backdrop'))}
        {ReactDOM.createPortal(<Overlay>{props.children}</Overlay>, document.getElementById('modal'))}

    </div>
}

export default Modal