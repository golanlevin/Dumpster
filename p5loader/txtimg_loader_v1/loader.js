var Files = {};

function loadImageLossless(url,callback){
  //get rid of premultiplied alpha
  //https://stackoverflow.com/a/60564905
  var img = new Image();
  img.src = url;
  img.addEventListener('load', function () {
    let canvas = document.createElement('canvas');
    let gl = canvas.getContext("webgl2");
    if (!gl){
      gl = canvas.getContext("webgl");
    }
    // monkey patch safari drawBuffers
    // https://stackoverflow.com/a/37071729
    if (!gl.drawBuffers){
      var ext = gl.getExtension("WEBGL_draw_buffers");
      if (!ext) {
        console.log("i'm sorry.");
      } 
      for (var key in ext) {
        var value = ext[key];
        if (typeof value === 'function') {
          value = value.bind(ext);
        }
        var newKey = key.replace(/_?WEBGL/, '');
        gl[newKey] = value;
      }
    }
    gl.activeTexture(gl.TEXTURE0);
    let texture = gl.createTexture();
    gl.bindTexture(gl.TEXTURE_2D, texture);
    const framebuffer = gl.createFramebuffer();
    gl.bindFramebuffer(gl.FRAMEBUFFER, framebuffer);
    gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, texture, 0);
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, this);
    gl.drawBuffers([gl.COLOR_ATTACHMENT0]);
    let data = new Uint8Array(this.width * this.height * 4);
    gl.readPixels(0, 0, this.width, this.height, gl.RGBA, gl.UNSIGNED_BYTE, data);
    callback(data);
  });
}

function loadClips(callback){
  var startTime = performance.now();

  loadImageLossless("text.png",function(data8){
    var data2 = [];
    for (var i = 0; i < data8.length; i++){
      // if (i<100)console.log(data8[i])
      data2.push((data8[i] >> 6)&0b11)
      data2.push((data8[i] >> 4)&0b11)
      data2.push((data8[i] >> 2)&0b11)
      data2.push((data8[i]     )&0b11)
    }
    var data6 = [];
    for (var i = 0; i < ~~(data2.length/3)*3; i+=3){
      data6.push((data2[i]<<4) | (data2[i+1]<<2) | (data2[i+2]));
    }
    console.log(data6);
    // console.log(data2.length,data6.length)
    var i = 0;
    var clip = "";
    while (i < data6.length){    
      if (data6[i] == 0){
        var x = data6[i+1]
        if (x === 0){
          // console.log(FILENAMES[0],clip);
          Files[FILENAMES[0]] = clip;
          clip = "";
          FILENAMES.shift();
          if (!FILENAMES.length){
            break;
          }
        }else if (x == 1){
          clip += "\n";
        }else if (3 <= x && x <= 17){
          clip += String.fromCharCode(x-3+33);
        }else if (18 <= x && x <= 24){
          clip += String.fromCharCode(x-18+58);
        }else if (25 <= x && x <= 30){
          clip += String.fromCharCode(x-25+91);
        }else if (31 <= x){
          clip += String.fromCharCode(x-31+123);
        }else{
          clip += "?";
        }
        i++;
      }else{
        var x = data6[i];
        if (x == 1){
          clip += " ";
        }else if (2 <= x && x <= 27){
          clip += String.fromCharCode(x-2+65);
        }else if (28 <= x && x <= 53){
          clip += String.fromCharCode(x-28+97);
        }else if (54 <= x && x <= 64){
          clip += String.fromCharCode(x-54+48);
        }
      }
      i++;
    }
    var dur = performance.now()-startTime;
    console.log(`loaded in ${dur/1000} seconds.`)
    // console.log(Object.keys(Files).length)
    if (callback) callback(Files);
  });
}