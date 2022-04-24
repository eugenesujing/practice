import Modal from '../../UI/Modal'
import classes from './OrderForm.module.css'

function ConfirmOrder(props){

    return <Modal>
        <p>Your Order Has Been Placed!</p>
        <form>
            <div className = {classes['form-actions']}>
                <button type = 'submit' onClick = {props.remove}>Close</button>
                <button type = 'submit' onClick = {props.remove} className = {classes['button--alt']}>OK</button>
            </div>
        </form>
    </Modal>
}

export default ConfirmOrder