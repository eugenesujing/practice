
  let locations = document.querySelectorAll('.location');
  let workers = document.querySelectorAll('.worker');
  locations.forEach(item=>{
      item.addEventListener('click',
      () => {

        locations.forEach(location=>{
          //only one chocie can have class show
          if(location.classList.contains('show')){
            location.classList.toggle('show');
          }
        }
        )
        item.classList.toggle('show');
      });
    })
    workers.forEach(item=>{
        item.addEventListener('click',
        () => {

          workers.forEach(worker=>{
            //only one chocie can have class show
            if(worker.classList.contains('show')){
              worker.classList.toggle('show');
            }
          }
          )
          item.classList.toggle('show');
        });
      })
