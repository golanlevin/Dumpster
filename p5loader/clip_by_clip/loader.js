var Files = {};

function loadOne(url,callback){
  var xhttp = new XMLHttpRequest();
  xhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      // Typical action to be performed when the document is ready:
      callback(xhttp.responseText);
    }
  };
  xhttp.open("GET", url, true);
  xhttp.send();
}

function loadBatch(urls,callback){
  let loadCount = 0;
  for (let i = 0; i < urls.length; i++){
    loadOne("text/"+urls[i],function(txt){
      Files[urls[i]] = txt;
      loadCount ++;
    });
  }
  function checkComplete(){
    if (loadCount == urls.length){
      callback();
    }else{
      setTimeout(checkComplete,100);
    }
  }
  checkComplete();
}


function loadAll(batchSize,callback){
  function loadIter(i){
    if (i > FILENAMES.length){
      console.log("loading complete.");
      return callback();
    }
    console.log(`loading ${i}-${i+batchSize} of ${FILENAMES.length}...`);

    loadBatch(FILENAMES.slice(i,i+batchSize),function(){
      setTimeout(function(){
        loadIter(i+batchSize)
      },100);
    });
  }
  loadIter(0);
}