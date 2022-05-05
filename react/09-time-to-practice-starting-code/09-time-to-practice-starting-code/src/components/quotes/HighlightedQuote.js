import classes from './HighlightedQuote.module.css';

const HighlightedQuote = (props) => {
  return (
    <figure className={classes.quote}>
      <p>{props.quote.text}</p>
      <figcaption>{props.quote.author}</figcaption>
    </figure>
  );
};

export default HighlightedQuote;
