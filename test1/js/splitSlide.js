const wrapper = document.querySelector('.wrapper');
const handle = document.querySelector(".handle");
const topLayer = document.querySelector(".top");
var skew = 1000;
var delt = 0;
wrapper.addEventListener('mousemove',slide);

function slide(e){
  delt = 0.5*(e.clientX-window.innerWidth/2);
  handle.style.left = e.clientX + delt +'px';
  topLayer.style.width = skew + e.clientX +delt +'px';
}
