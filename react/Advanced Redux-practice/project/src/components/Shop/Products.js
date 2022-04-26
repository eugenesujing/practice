import ProductItem from './ProductItem';
import classes from './Products.module.css';

const DUMMY_ITEMS = [{
    id: 'first-book',
    title: 'first-book',
    price: 12.59,
    description: 'My first book'
},{
    id: 'second-book',
    title: 'second-book',
    price: 17.45,
    description: 'My second book'
}]

const Products = (props) => {
  return (
    <section className={classes.products}>
      <h2>Buy your favorite products</h2>
      <ul>
        {DUMMY_ITEMS.map(item => <ProductItem key={item.id} title = {item.title} price = {item.price} description = {item.description}/>)}
      </ul>
    </section>
  );
};

export default Products;
