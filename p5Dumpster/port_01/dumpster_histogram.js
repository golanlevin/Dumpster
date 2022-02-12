//-------------------------------------------------------------
class HistogramDatum {
  constructor (i, n){
    this.I=i; // index
    this.N=n; // number (count)
  }
}

class DumpsterHistogram {

  //-------------------------------------------------------------
  constructor (bpd05, x, y, w, h, kos) {

    this.KOS = kos; 
    this.breakupsPerDay2005 = bpd05;

    this.bMouseInside = false;
    this.hiliteMode = DH_HILITEMODE_NONE;

    this.width  = w;
    this.height = h;
    this.xoffset = x;
    this.yoffset = y;

    this.monthLengths2005 = [
        0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31, 31];
    this.bandNames = [
        "Year", "Month", "Week", "Day"];
    this.monthNames = [
        "JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC", "---"];
    this.dayNames = [
        "SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];

    this.bands = [];
    this.nBands = 0;
    this.bandH = 0;

    this.CS = new HistogramColorScheme();
    this.mouseXf = 0;
    this.mouseYf = 0;
    this.bUseMouseYMagnification = true;
    this.bUseBackgroundImage = false;

    this.curdat_r = 0;
    this.curdat_g = 0;
    this.curdat_b = 0;
    this.curdat_rT = 0;
    this.curdat_gT = 0;
    this.curdat_bT = 0;

    this.bUseBogusData = false;
    this.setupDumpsterHistogram();

    this.skipList = [
      1, 5, 10, 25, 50, 100, 250, 500, 1000, 2500, 5000, 10000, 25000, 50000, 100000];
    this.FADE_LABEL_TIME  = 333.3;
    this.majorLabelSkip     = 100;
    this.prevMajorLabelSkip = 250;
    this.labelSkipTime      = 0;

    print("Created DumpsterHistogram.");
  }

  //-------------------------------------------------------------
  setupDumpsterHistogram() {

    if (this.bUseBogusData) {
      var I = 0;
      this.nData = 365;
      this.nDatam1 = this.nData-1;
      this.data = [];
      for (var i=0; i<this.nData; i++) {
        var N = int(round(130.0 * (0.2 + random(0, 1)*0.8)));
        this.data[i] = new HistogramDatum(I, N);
        I++;
      }
      this.indexLo = 0;
      this.indexHi = 364;

    } else {
      var nFileLines = breakupsPerDay2005.length;
      this.nData = nFileLines;
      this.nDatam1 = this.nData-1;

      var I = 0;
      this.data = []; //new HistogramDatum[this.nData];
      for (var i=0; i < this.nDatam1; i++) {
        var N = breakupsPerDay2005[i+1];
        this.data[i] = new HistogramDatum(I, N);
        I++;
      } 
    
      this.data[this.nDatam1] = new HistogramDatum(I, 0);
      this.indexLo = 0;
      this.indexHi = this.nData-1;
    }

    this.mouseBlur  = 0.70;
    this.mousePivot = 0.5;
    this.mousePower = 1.0;

    this.nBands     = 1;
    this.bandH      = 10;

    this.histogramL = this.xoffset + HEART_WALL_L;
    this.histogramR = this.xoffset + DUMPSTER_APP_W - 1;
    this.histogramW = this.histogramR - this.histogramL;
    this.histogramT = this.yoffset + 0;
    this.histogramB = this.yoffset + ((DUMPSTER_APP_H+1)-2 - (this.nBands*this.bandH));
    this.histogramH = this.histogramB - this.histogramT;
    this.histogramValueScaleFactor = 1.0;

    this.tmpPixelBounds = [0,0,0,0]; // L,R,T,B
    this.bands = [];
    for (var i=0; i<this.nBands; i++) {
      this.bands[i] = new Band(i, this.bandNames, this);
      this.bands[i].setDimensions (
        this.histogramL, 
        (DUMPSTER_APP_H-1 - (this.nBands*this.bandH)) + (this.bandH*i), 
        this.histogramW, 
        this.bandH);
      this.bands[i].computeBoundaries(this.data, this.nData);
    }

    this.monthStartDays = [];
    var count = -1; 
    for (var i=0; i<13; i++) {
      this.monthStartDays[i] = count;
      count += this.monthLengths2005[i+1];
    }
  }

  //-------------------------------------------------------------
  cursorToPixelBounds() {
    // search downward and upward from the cursor pixel,
    // whose data index we (are required to) also know.

    var mouseXi = floor(this.mouseXf);
    mouseXi = max(this.histogramL, min(this.histogramR-1, mouseXi));

    var pixela = -1;
    var pixelb = -1;
  
    pixela = this.dataIndexToPixel(this.dataIndexOfCursor);
    if ((this.dataIndexOfCursor < (this.indexHi-1)) && 
      (mouseXi < (this.histogramR-1))) {
      pixelb = this.dataIndexToPixel(this.dataIndexOfCursor+1);
    } else {
      pixelb = this.histogramR-1;
    }
    // patch a problem which appears in highly compressed situations.
    if (pixelb < pixela) {
      pixelb = pixela;
    }
  
    // note that tmpPixelBounds[2] and [3] are set in drawHistogramData().
    this.tmpPixelBounds[0] = pixela;
    this.tmpPixelBounds[1] = pixelb;
    // return this.tmpPixelBounds;
  }

  //-------------------------------------------------------------
  // inverse warping yields two results:
  // frac = mousePivot * (1.0 - pow((1.0-(warped/mousePivot)), 1.0/mousePower));
  // frac = mousePivot + (1.0-mousePivot)*pow((warped - mousePivot)/(1.0-mousePivot), 1.0/mousePower);
  dataIndexToPixel (index) {
    var pix = -1;
    var frac = 0.5;
    if ((index >= this.indexLo) && (index < this.indexHi)) {
      var warped = (this.index - this.indexLo)/(this.indexHi - this.indexLo);
      var ommp = 1.0-this.mousePivot;
      if (index <= this.dataIndexOfCursor) {
        frac = this.mousePivot * (1.0 -  pow((1.0-(warped/this.mousePivot)), 1.0/this.mousePower));
      } else {
        frac = this.mousePivot + ommp * pow((warped - this.mousePivot)/ommp, 1.0/this.mousePower);
      }
      pix = round(this.histogramL + frac*this.histogramW);
    }
    return pix;
  }

  //-------------------------------------------------------------------
  warpFraction ( frac, power) {
    var output = frac;
    var cube;

    if (frac <= this.mousePivot) {
      cube = 1 - (frac/this.mousePivot);
      cube = pow (cube, power);
      output  = this.mousePivot * (1-cube);
    } 
    else {
      var oneMpivot = 1.0-this.mousePivot;
      cube = (frac-this.mousePivot)/(oneMpivot);
      cube = pow (cube, power);
      output  = this.mousePivot + oneMpivot*cube;
    }
    return output;
  }
   
  //-------------------------------------------------------------
  pixelToDataIndex (hpixel) {
    var fraca = float(hpixel-this.histogramL)/ this.histogramW;
    fraca = min(1.0, max(0.0, fraca));
    fraca = this.warpFraction (fraca, this.mousePower);

    var nDataToShowf = float(this.indexHi - this.indexLo);
    var indexa = this.indexLo + int(floor(fraca * nDataToShowf));
    indexa = min(this.indexHi, max(this.indexLo, indexa));
    return indexa;
  }

  //-------------------------------------------------------------
  dataIndexToDateString (index) {	
    var out = "";
    if ((index >= 0) && (index < this.nData)) {
      var monthCount = 0;
      while ( (index > this.monthStartDays[monthCount]) && (monthCount < 12)) {
        monthCount++;
      }
      monthCount--;
      out = this.dayNames[index%7] + " " + 
            this.monthNames[(monthCount%12)] + " " + (index - this.monthStartDays[monthCount]);
    }
    return out;
  }

  //-------------------------------------------------------------
  getMaxDataValueInIndexRange(loi, hii) {
    loi = max(0, min(this.nDatam1, loi));
    hii = max(0, min(this.nDatam1, hii));

    var maxInRange = 0;
    var rawDataValue = 0;
    for (var i=loi; i<hii; i++) {
      rawDataValue = this.data[i].N;
      if (rawDataValue > maxInRange) {
        maxInRange = rawDataValue;
      }
    }
    return maxInRange;
  }

  //-------------------------------------------------------------
  updateHistogramVerticalScale() {
    this.histogramValueMax  = this.getMaxDataValueInIndexRange(this.indexLo, this.indexHi);
    this.histogramValueMax  = max(1.0, this.histogramValueMax);
    var targetHeight        = this.histogramH * HISTOGRAM_SPACE_OCCUPANCY;
    this.histogramValueScaleFactor = targetHeight / this.histogramValueMax;
  }

  //-------------------------------------------------------------
  // a surprising amount of code is necessary to render the labels correctly.
  drawHistogramVerticalScale() {
    var now = millis();

    // dimension the vertical label.
    var vertL = 0;
    var vertR = this.histogramL;
    var vertW = vertR - vertL;
    var vertT = this.histogramT;
    var vertB = this.histogramB;
    var vertH = this.histogramH;
    var vertHf = float(vertH);
    var vertTextT = vertT + 9;
    var keyFontAscent = 8.0;
    var labelDensity = 6;//12.0;
    var charW = 4;

    var vertTxCol = this.CS.vertTxCol;
    var vertLnCol = this.CS.vertLnCol;
    var vertBgCol = this.CS.vertBgCol;
  
    // fill the background of the vertical indicator.
    noStroke();
    fill (vertBgCol);
    rect (vertL, vertT, vertW, vertH);

    textFont (font6, 6); 
  
    // hunt for the label that fits.
    var prevMLS = this.majorLabelSkip;
    this.majorLabelSkip = max(1, floor(keyFontAscent*labelDensity/(vertHf/this.histogramValueMax)));
    var ind = this.skipList.length-1;
    var skindex = 0;
    var minn = 1000000;
    while (ind >= 0) {
      var fact = float(this.skipList[ind]) / this.majorLabelSkip;
      if (abs(fact - 1) < minn) {
        minn = fact;
        skindex = ind;
      }
      ind--;
    }

    skindex = max(0, min(skindex, this.skipList.length-1));
    this.majorLabelSkip = this.skipList[skindex];
    if (prevMLS != this.majorLabelSkip) {
      this.prevMajorLabelSkip = prevMLS;
      this.labelSkipTime = now;
    }
    var spaceSizeMaj  = this.majorLabelSkip * this.histogramValueScaleFactor;
    var spaceSizePrev = this.prevMajorLabelSkip * this.histogramValueScaleFactor;
  
    
    // draw the main labels.
    var count;
    var nChars;
    var labelY;
    var labelStr;
    var labelInt;
    var visibility = float(now - this.labelSkipTime)/this.FADE_LABEL_TIME; /// 0...->1
    if (visibility < 1.0) {
  
      // fade labels in and out
      var sgr =       visibility*(vertBgCol-vertLnCol) + vertLnCol;
      var tgr =       visibility*(vertBgCol-vertTxCol) + vertTxCol;
      var shr = (1.0-visibility)*(vertBgCol-vertLnCol) + vertLnCol;
      var thr = (1.0-visibility)*(vertBgCol-vertTxCol) + vertTxCol;

      // previous ones
      labelY = vertB - spaceSizePrev; 
      count = 1;
      fill  (tgr, tgr, tgr);
      while (labelY > vertTextT) {
        labelInt = int(count * this.prevMajorLabelSkip);
        labelStr = "" + labelInt; 

        if ((labelInt%majorLabelSkip) != 0) {
          var labelYi = int(round(labelY));
          beginShape(LINES);
          stroke(vertBgCol);
          vertex(0, labelYi);
          stroke(sgr, sgr, sgr);
          vertex(vertR, labelYi);
          endShape();

          nChars = labelStr.length;
          text(labelStr, (vertR-nChars*charW-1), labelYi-2);
        }
        labelY -= spaceSizePrev;
        count++;
      }
  
      // new (current) ones
      labelY = vertB - spaceSizeMaj; 
      count = 1;
      while (labelY > vertTextT) {
        labelInt = int(count*majorLabelSkip);
        labelStr = "" + labelInt; 

        if ((labelInt % this.prevMajorLabelSkip) == 0) {
          stroke(vertLnCol);
          fill  (vertTxCol);
        } 
        else {
          stroke(shr, shr, shr);
          fill  (thr, thr, thr);
        }
        var labelYi = int(round(labelY));
        beginShape(LINES);
        vertex(vertR, labelYi);
        stroke(vertBgCol);
        vertex(0, labelYi);
        endShape();

        nChars = labelStr.length;
        text(labelStr, (vertR-nChars*charW-1), labelYi-2);
        labelY -= spaceSizeMaj;
        count++;
      }
      
    } else {
      // just draw the labels.
      labelY = vertB - spaceSizeMaj;
      count = 1;
      fill  (vertTxCol);
      while (labelY > vertTextT) {
        var labelYi = int(round(labelY));

        beginShape(LINES);
        stroke(vertBgCol);
        vertex(0, labelYi);
        stroke(vertLnCol);
        vertex(vertR, labelYi);
        endShape();

        labelInt = int(count * this.majorLabelSkip)
        labelStr = "" + labelInt;
        nChars = labelStr.length;
        text(labelStr, (vertR-nChars*charW-1), labelYi-2);
        labelY -= spaceSizeMaj;
        count++;
      }
    }
  }


  //-------------------------------------------------------------
  drawHistogramData(){
    noSmooth();

    var  fraca;
    var  fracb;
    var  evenWeek; 
    var  evenDay;
    var  nonUnaryRange = false;
    var  histTshad = floor (this.histogramT + 0.5*this.histogramH);
  
    var  indexa;
    var  indexb; 
    var  indexRange;
    var  nDataToShow = this.indexHi - this.indexLo;
    var  rawDataValue;
  
    var  Y;
    var  nDataToShowf = nDataToShow;
    var  nXinv = 1.0/(this.histogramW);

    var  band0 = this.CS.bandFillColor0;
    var  band1 = this.CS.bandFillColor1;
    var  band2 = this.CS.bandFillColor2;
    var  bandM = this.CS.bandMouseColor;
    var  bandP = this.CS.bandCapColor;
    var  bandC;
  
    var  week1 = this.CS.histogramBackgroundColor1;
    var  week2 = this.CS.histogramBackgroundColor2;
    var  week3 = this.CS.histogramBackgroundColor3;
    var  weekC;

    var  week1s = this.CS.histogramBackgroundColor1s;
    var  week2s = this.CS.histogramBackgroundColor2s;
    var  week3s = this.CS.histogramBackgroundColor3s;
    var  weekS;
  
    var  histbgCol = this.CS.histogramBackgroundFieldCol;

    var  fixi;
    var  bandCurCol = color(this.curdat_r, this.curdat_g, this.curdat_b);
    
    //------------------------------------------
    // for each pixel across the histogram
    for (var i=this.histogramL; i<this.histogramR; i++) {
      fixi = i+0.5;

      fraca = (i  -this.histogramL)*nXinv;
      fracb = (i+1-this.histogramL)*nXinv;

      // non-linearize the view
      fraca = this.warpFraction(fraca, this.mousePower);
      fracb = this.warpFraction(fracb, this.mousePower);

      // compute the bounds of the window-of-days
      indexa = this.indexLo + int(fraca * nDataToShowf);
      indexb = this.indexLo + int(fracb * nDataToShowf);

      indexa = min(this.nDatam1, max(0, indexa));
      indexb = min(this.nDatam1, max(0, indexb));
      indexRange = (indexb - indexa);
      nonUnaryRange = (indexRange > 1);
  
      //------------------------------------------
      // compute the maximum value within the window-of-days
      var localValueMax = 0;
      if (nonUnaryRange) {
        for (var j=indexa; j<=indexb; j++) {
          rawDataValue = this.data[j].N;
          if (rawDataValue > localValueMax) {
            localValueMax = rawDataValue;
          }
        }
      } else {
        localValueMax = this.data[indexa].N;
      }
      Y = this.histogramB - (localValueMax * this.histogramValueScaleFactor);

      evenDay = ((indexa % 2)== 0);
      bandC = (evenDay && (indexRange == 0)) ? band0 : band1;

      if (indexa == this.dataIndexOfCursor) {
        this.dataValueOfCursor = localValueMax;
        this.tmpPixelBounds[2] = int(this.histogramB - (this.dataValueOfCursor * this.histogramValueScaleFactor));
        this.tmpPixelBounds[3] = this.histogramB;

        //stroke(bandM);
        stroke(bandCurCol);
        line(fixi, this.histogramB, fixi, Y);

      } else {
        stroke(bandC);
        line(fixi, this.histogramB, fixi, Y);
      }
      // improve contrast above data
      stroke(bandP);
      point(fixi, Y-1);
    }
  }
  
    
  //-------------------------------------------------------------
  loop() {
    this.updateMouseInformation();       // DONE
    this.updateHistogramVerticalScale(); // DONE
    this.dataIndexOfCursor = this.pixelToDataIndex (floor(this.mouseXf));

    this.drawBackground();               // DONE
    this.drawHistogramData();            // DONE
    this.drawCurrentDataBounds();        // DONE
    this.drawBands();                    // DONE
    this.drawOverallFrames();            // DONE
  }

  
  //-------------------------------------------------------------
  drawCurrentDataBounds() {
    this.cursorToPixelBounds();

    var p = this.tmpPixelBounds[0];
    var q = this.tmpPixelBounds[1];
    var t = this.tmpPixelBounds[2];
    this.centerOfBoundsX = min(q, max(p, this.centerOfBoundsX));

    var A = 0.6;
    var B = 1.0-A;
    this.centerOfBoundsX = A*this.centerOfBoundsX + B*((p+q)/2.0);

    // stroke(this.CS.bandMouseColor);
    var bandCurCol = color(this.curdat_r, this.curdat_g, this.curdat_b);
    stroke(bandCurCol);
    line (this.centerOfBoundsX, t, this.centerOfBoundsX, this.histogramT);

    textFont (font6, 6);
    fill(bandCurCol); //this.CS.dateLabelColor); 
    var strY = this.histogramT + 9;

    var nbupCh = 0;
    var nbupStr = "";
    if ((this.dataIndexOfCursor >= 0) && (this.dataIndexOfCursor < this.nData)) {
      nbupStr += this.data[this.dataIndexOfCursor].N;
      nbupCh  = nbupStr.length;
    }
    var dateString = this.dataIndexToDateString(this.dataIndexOfCursor);

    if ((this.histogramR - this.centerOfBoundsX) > 52) {
      text(dateString, this.centerOfBoundsX+4, strY); 
      text(nbupStr, this.centerOfBoundsX-nbupCh*6+1, strY);
    } 
    else {
      text(dateString, this.centerOfBoundsX-42, strY); 
      text(nbupStr, this.centerOfBoundsX+4, strY);
    }
  }


  //-------------------------------------------------------------
  informOfMouse(x, y, p) {

    this.bMouseInside = false;
    if ((y >=  this.histogramT) && 
        (x <=  this.histogramR) && 
        (x >=  this.histogramL) && 
        (y <= (this.histogramT + HISTOGRAM_H))) {

      this.bMouseInside = true;
      this.mouseX = min(this.histogramR, x);

      if (this.bUseMouseYMagnification) {
        this.mouseY = y;
      } else {
        this.mouseY = this.histogramT + (this.histogramH * sqrt(0.1));  //0.316..
      }
      this.hiliteMode = DH_HILITEMODE_MAUS;
    }

    //---------------------------
    if (this.bMouseInside == false) {

      // hack, use the KOS to obtain a fake mouse position
      var breakupIndex = DUMPSTER_INVALID;
      var moBreakupIndex = 0;/// RESTORE THIS ONCE KOS IS WORKING: var moBreakupIndex = KOS.currentMouseoverBreakupId;
      var seBreakupIndex = 0;/// RESTORE THIS ONCE KOS IS WORKING: var seBreakupIndex = KOS.currentSelectedBreakupId;

      if (moBreakupIndex != DUMPSTER_INVALID) {
        if (moBreakupIndex == seBreakupIndex) {
          breakupIndex = seBreakupIndex;
          this.hiliteMode = DH_HILITEMODE_SELE;
        } 
        else {
          breakupIndex = moBreakupIndex;
          this.hiliteMode = DH_HILITEMODE_OVER;
        }
      } 
      else {
        if (seBreakupIndex != DUMPSTER_INVALID) {
          breakupIndex = seBreakupIndex;
          this.hiliteMode = DH_HILITEMODE_SELE;
        } 
        else {
          breakupIndex = DUMPSTER_INVALID;
          this.hiliteMode = DH_HILITEMODE_NONE;
        }
      }

      if (breakupIndex != DUMPSTER_INVALID) {
        var breakupDate = 0; ////// FIX WHEN BM exists BM.bups[breakupIndex].date;
        var kosDateFrac = breakupDate / (this.indexHi-1);
        kosDateFrac = max(0, min(1, kosDateFrac));

        this.mouseX = this.histogramL + kosDateFrac*(this.histogramR-this.histogramL);
        this.mouseY = this.histogramT + (this.histogramH * sqrt(0.1));  //0.316..
      }
    }

    switch (this.hiliteMode) {
      case DH_HILITEMODE_NONE:
      case DH_HILITEMODE_MAUS:
        this.curdat_rT = red(this.CS.bandMouseColor);
        this.curdat_gT = green(this.CS.bandMouseColor);
        this.curdat_bT = blue(this.CS.bandMouseColor);
        break;
      case DH_HILITEMODE_OVER:
        this.curdat_rT = 16;
        this.curdat_gT = 64;
        this.curdat_bT = 255;
        break;
      case DH_HILITEMODE_SELE:
        this.curdat_rT = 255;
        this.curdat_gT = 255;
        this.curdat_bT = 0;
        break;
    }

    this.curdat_r = DH_BLURA*this.curdat_r  + DH_BLURB*this.curdat_rT;
    this.curdat_g = DH_BLURA*this.curdat_g  + DH_BLURB*this.curdat_gT;
    this.curdat_b = DH_BLURA*this.curdat_b  + DH_BLURB*this.curdat_bT;
  }

  //-------------------------------------------------------------
  updateMouseInformation() {

    var A = this.mouseBlur;
    var B = 1.0 - A;
    var shiftKeyDown = (keyIsPressed && (keyCode == 16));
    var ctrlKeyDown  = (keyIsPressed && (keyCode == 17));
    if (shiftKeyDown == false) {
      this.mouseXf = A*this.mouseXf + B*this.mouseX;
    }
    if (ctrlKeyDown == false) {
      this.mouseYf = A*this.mouseYf + B*this.mouseY;
    }

    if (this.bUseMouseYMagnification) {
      var fracmy = float(this.mouseYf-this.histogramT)/float(this.histogramH);
      fracmy = min(1.0, max(0.0, fracmy));
      fracmy = pow(fracmy, 2.0);
      this.mousePower = fracmy * 0.75 + 2.0;
    } 
    else {
      this.mousePower = 2.0; // thus mousePower is no longer dependent on this.mouseY;
    }

    this.mousePivot = float(this.mouseXf - this.histogramL)/float(this.histogramW);
    this.mousePivot = max(0.0000001, min(0.999999, this.mousePivot));
  }
  
  //-------------------------------------------------------------
  drawBackground() {
    if (this.bUseBackgroundImage) {
      if (histbgImg != null){
        image(histbgImg, this.histogramL, this.histogramT); 
      }
      stroke(255, 200, 200, 24);
      line(this.histogramL, this.histogramT+1, this.histogramR, this.histogramT+1);
    } 
    else {
      noStroke();
      fill(this.CS.histogramBackgroundFieldCol);
      rect(this.histogramL, this.histogramT, this.histogramW, this.histogramH); 
      stroke(255, 200, 200, 24);
      line(this.histogramL, this.histogramT+1, this.histogramR, this.histogramT+1);
    }
  }

  //-------------------------------------------------------------
  drawBands() {

    // draw the scrolling time-axis bands
    for (var i=0; i<this.nBands; i++) {
      this.bands[i].render();
      this.bands[i].drawBoundaries();
    }

    // draw labels for the bands
    noStroke();
    fill(0);
    rect(this.xoffset, this.yoffset, this.histogramL, this.histogramH);

    fill(64);
    rect(this.xoffset, this.histogramB, this.histogramL, 10);

    fill(128);
    noSmooth(); 
    textFont(font6, 6);
    text("2005", int(this.bands[0].L - 19), int(this.bands[0].B - 2));
  }


  //-------------------------------------------------------------
  drawOverallFrames() {
    stroke(0);
    noFill();
    rect(this.xoffset, this.yoffset, this.width-1, this.height-1);
    line(this.histogramL-1, this.histogramT, this.histogramL-1, this.histogramT + this.height-1);
    line(this.xoffset, this.histogramB, this.histogramL, this.histogramB);
  }

  //-------------------------------------------------------------
  keyPressed() {
    if (key == 'a') {
      for (var i=0; i<this.nData; i++) {
        this.data[i].N += 10;
      }
    } 
    else if (key == 'b') {
      for (var i=0; i<this.nData; i++) {
        this.data[i].N -= 10;
      }
    }
  }

  
}


//-------------------------------------------------------------
class Band {

  constructor (position, bandNames, thedh){ //ml05) {
    this.dh = thedh; 
    this.ID = position;
    this.name = bandNames[this.ID];
    this.nBoundaries = [];
    this.monthLengths2005 = this.dh.monthLengths2005; //ml05;

    this.boundaries = [];
    this.boundaryLocs = [];
    this.boundarySeps = [];
    this.nBoundaries = 0;
  }

  //------------------
  setDimensions (l, t, w, h) {
    this.W = w;
    this.H = h;
    this.L = l;
    this.T = t;
    this.R = this.L+this.W;
    this.B = this.T+this.H;
  }
  
  //------------------
  render() {
    noStroke();
    fill (this.dh.CS.bandBgCol);
    rect (this.L, this.T, this.W, this.H);

    stroke(this.dh.CS.bandEdgeColor);
    noFill();
    rect(this.L-1, this.T, this.W+1, this.H);
  }
  
  //------------------
  drawBoundaries() {
    if (this.dh.nBoundaries > 0) {

      var boundaryIndex;
      var boundaryPixel = 0;
      var boundaryPixelPrev = 0;

      // compute the locations of the boundary marks,
      // and their distances from one to the next.
      for (var i=1; i<nBoundaries; i++) {
        // fetch the pre-stored day at which a boundary occurs.
        boundaryIndex = this.boundaries[i];

        // compute the pixel at which the boundary should be drawn.
        boundaryPixel   = this.dh.dataIndexToPixel (boundaryIndex);
        if (boundaryPixel == -1) {
          boundaryPixel = this.dh.histogramR;
        } 

        this.boundaryLocs[i]   = boundaryPixel;
        this.boundarySeps[i-1] = boundaryPixel - boundaryPixelPrev;
        boundaryPixelPrev = boundaryPixel;
      }

      var sep = 0;
      var loc = 0;
      var top = floor(T)+1;
      var bot = floor(B)-1;
      var mid = (top+bot)/2;
      var texbot = bot-1;

      stroke(this.dh.CS.vertLnCol);
      textFont(font6);
      textSize(6);

      var txC = this.dh.CS.vertTxCol;
      var bgC = this.dh.CS.bandBgCol;
      var difC = bgC - txC;
      var minSep = 0;
      var maxSep = 80;
      var texfill;
      var texfrac;

      for (var i=0; i<nBoundaries; i++) {
        sep = this.boundarySeps[i];
        loc = this.boundaryLocs[i];
        if ((loc == 0) && (i==0)) loc = this.dh.histogramL; // WOW big ERROR

        if (i > 0) {
          line (loc, top, loc, bot);
        }

        texfrac = max(0, min((sep-minSep), maxSep))/maxSep;
        texfill = txC + difC*(1.0 - texfrac);
        fill (0, 0, 0);//texfill);
        text(this.dh.monthNames[i%12], loc+3, texbot);
      }
    }
  }
  
  
  //------------------
  computeBoundaries(dhdata, dhndata) {

    // compute the days at which there are scale-specific data boundaries.
    // for example, multiples of 7 for weeks, month-boundaries, and year-boundaries.
    // weeks are the finest level of granularity we care about here.
    var maxPossibleNboundaries = dhndata;
    // print("this.dh = " + this.dh);

    var nMos = this.dh.monthLengths2005.length;
    this.boundaries = [];
    this.boundaryLocs = [];
    this.boundarySeps = [];
    this.nBoundaries = 0;
    for (var i=0; i<maxPossibleNboundaries; i++){
      this.boundaries[i] = 0;
      this.boundaryLocs[i] = 0;
      this.boundarySeps[i] = 0;
    }

    var count = 0;
    switch(this.ID) {
        
      //--------------
      case 1: // WEEKS
        for (var i=0; i<dhndata; i++) {
          if (i%7 == 0) {
            this.boundaries[count] = i;
            count++;
          }
        }
        this.nBoundaries = count;
        break;

      //--------------
      case 0: // MONTHS
        var dayCount = 0;
        for (var i=0; i<nMos; i++) {
          dayCount += this.dh.monthLengths2005[i];
          this.boundaries[count] = dayCount;
          count++;
        }
        this.nBoundaries = count;
        break;
    
      //--------------
      case -1: // YEARS
        for (var i=0; i<dhndata; i++) {
          if (i%365 == 0) {
            this.boundaries[count] = i;
            count++;
          }
        }
        this.nBoundaries = count;
        break;
      
      //--------------
      default:
        break;
    }
  }

}
