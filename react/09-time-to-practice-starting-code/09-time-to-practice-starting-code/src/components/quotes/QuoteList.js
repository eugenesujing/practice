import { Fragment } from 'react';
import {useHistory, useLocation} from 'react-router-dom'

import QuoteItem from './QuoteItem';
import classes from './QuoteList.module.css';

function sorting(quotes,isAscending){
    return quotes.sort((A,B)=>{
        if(isAscending){
            return A.id>B.id ? 1: -1
        }else{
            return A.id>B.id ? -1:1
        }

    })

}

const QuoteList = (props) => {
    const history = useHistory()
    const location = useLocation()
    const param = new URLSearchParams(location.search)
    const sortingAsc = param.get('sort') === 'asc'
    const sortedQuotes = sorting(props.quotes,sortingAsc)

    const onSortHandler = ()=>{
        history.push({
            pathname : location.pathname,
            search:`?sort=${sortingAsc? 'desc':'asc'}`
        })
    }

  return (
    <Fragment>
    <div className = {classes.sorting}>
        <button onClick={onSortHandler}>Sort {sortingAsc ? 'Descending':'Ascending'}</button>
    </div>

      <ul className={classes.list}>
        {sortedQuotes.map((quote) => (
          <QuoteItem
            key={quote.id}
            id={quote.id}
            author={quote.author}
            text={quote.text}
          />
        ))}
      </ul>
    </Fragment>
  );
};

export default QuoteList;
