const form = document.querySelector('form');
const items = document.querySelector("ul");
const input = document.querySelector(".add");
const filter = document.querySelector(".search");

form.addEventListener('submit',add);
items.addEventListener('click',deleteLi);
filter.addEventListener('keyup',search);

function add(e){
  e.preventDefault();

  var li = document.createElement('li');
  var text = document.createTextNode(input.value);
  li.appendChild(text);
  var btn = document.createElement('a');
  btn.href="#";
  btn.className="delete";
  var textBtn = document.createTextNode('X');
  btn.appendChild(textBtn);
  li.appendChild(btn);

  items.appendChild(li);
}

function deleteLi(e){
  if(e.target.className =="delete"){
    items.removeChild(e.target.parentElement);
  }
}

function search(e){
  var text = e.target.value.toLowerCase();
  var lis =items.children;

    Array.from(lis).forEach((li) => {
      if(li.textContent.toLowerCase().indexOf(text)==-1){
        li.style.display='none';
      }else{
        li.style.display='block';

      }

    });





}
