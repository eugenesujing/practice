let indice = 1;
//show menubar when bar icon clicked
  document.querySelector('.menubar').addEventListener('click',
    () => document.querySelector('.menu-bar').classList.toggle('show'));
    document.querySelector('.home').addEventListener('click',
      () => document.querySelector('.menu-bar').classList.toggle('show'));
let updates = document.querySelectorAll('.update');

//change the border color of carousel card by their index
let len = updates.length;
  updates.forEach(item=>{

    if(indice%2==0){
      item.style.border = "#6495ED 1px solid";

    }
    indice = indice+1;
    if(indice == len){
      indice =1;
    }
  })
