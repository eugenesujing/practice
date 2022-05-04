import {NavLink} from 'react-router-dom'
import classes from './MainNavigation.module.css'

function MainNavigation(){
    return<div className = {classes.header}>
    <h2 className={classes.logo}>React Router</h2>
    <nav className = {classes.nav}>
        <ul>
            <li><NavLink activeClassName={classes.active} to='/quotes'>Quotes</NavLink></li>
            <li><NavLink activeClassName={classes.active} to='/add-quotes'>Add A Quote</NavLink></li>
        </ul>
    </nav>
    </div>
}

export default MainNavigation