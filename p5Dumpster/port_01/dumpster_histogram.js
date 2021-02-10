class DumpsterHistogram {

    /*
    int width;
    int height;
    int xoffset;
    int yoffset;
  
    float mouseX;
    float mouseY;
    boolean bMousePressed;
    boolean bKeyPressed;
    int key;
  
    PFont font6;
    HistogramColorScheme CS;
  
    boolean bUseBogusData;
    boolean bUseBackgroundImage;
    boolean bUseMouseYMagnification;
    PImage histbg;
  
    float mouseXf, mouseYf;
    float mouseBlur = 0.70f;
    float mousePivot = 0.5f;
    float mousePower = 1.0f;
    int   dataIndexOfCursor;
    float dataValueOfCursor;
    float centerOfBoundsX;
  
    int histogramL, histogramR, histogramW;
    int histogramT, histogramB, histogramH;
    float histogramValueScaleFactor;
    float histogramValueMax;
    int tmpPixelBounds[];
  
    final String bandNames[] = {
      "Year", "Month", "Week", "Day"
    };
     final String monthNames[] = {
      "JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC", "---"
    };
     final String dayNames[]   = {
      "SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"
    };
     final int monthLengths2005[] = {
      0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31, 31
    };
    int monthStartDays[];
  
    Band bands[];
    int nBands;
    int bandH;
  
    HistogramDatum data[];
    int nData, nDatam1;
    int indexLo, indexHi;
  
    KnowerOfSelections		KOS;
    boolean bMouseInside;
    int hiliteMode; 
    private static final int NONE = 0;
    private static final int OVER = 1;
    private static final int SELE = 2;
    private static final int MAUS = 3;
  
    float curdat_r;
    float curdat_g;
    float curdat_b;
    float curdat_rT;
    float curdat_gT;
    float curdat_bT;
    */
  
    //-------------------------------------------------------------
    constructor (x, y, w, h, kos) {
        this.KOS = kos; 

        this.bMouseInside = false;
        this.hiliteMode = 0;

        this.width  = w;
        this.height = h;
        this.xoffset = x;
        this.yoffset = y;

        // font6 = f6;
        this.monthLengths2005 = [
            0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31, 31];
        this.bandNames = [
            "Year", "Month", "Week", "Day"];
        this.monthNames = [
            "JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC", "---"];
        this.dayNames = [
            "SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];

        setupDumpsterHistogram();
    }
  
  
    //-------------------------------------------------------------
    setupDumpsterHistogram() {
  
        this.CS = new HistogramColorScheme();
        this.mouseXf = 0;
        this.mouseYf = 0;
    
        this.bUseMouseYMagnification = true;
        this.bUseBogusData = false;

        if (bUseBogusData) {
            var I = 0;
            this.nData = 365;
            this.nDatam1 = this.nData-1;
            this.data = []; //new HistogramDatum[nData];
            for (var i=0; i<this.nData; i++) {
                var N = Math.round(130.0 * (0.2 + random(0, 1)*0.8));
                this.data[i] = new HistogramDatum(I, N);
                I++;
            }
            this.indexLo = 0;
            this.indexHi = 364;

        } else {

            String lines[] = loadStrings("breakupsPerDay2005.txt"); //FIX
            var nFileLines = lines.length;
            this.nData = nFileLines;
            this.nDatam1 = this.nData-1;

            var I = 0;
            this.data = []; //new HistogramDatum[this.nData];
            for (var i=0; i < this.nDatam1; i++) {
                var N = lines[i+1];
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

        this.tmpPixelBounds = [0,0,0,0];// L,R,T,B
        this.bands = [];
        for (var i=0; i<this.nBands; i++) {
            this.bands[i] = new Band(i);
            this.bands[i].setDimensions (
                this.histogramL, 
                (DUMPSTER_APP_H-1 - (this.nBands*this.bandH)) + (this.bandH*i), 
                this.histogramW, 
                this.bandH);
            this.bands[i].computeBoundaries();
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
    
        var fraca;
        var fracb;
        var indexa = 0;
        var indexb = 0;
        var pixela = -1;
        var pixelb = -1;
    
        pixela = dataIndexToPixel(this.dataIndexOfCursor);
        if ((this.dataIndexOfCursor < (this.indexHi-1)) && 
            (mouseXi < (this.histogramR-1))) {
            pixelb = dataIndexToPixel(this.dataIndexOfCursor+1);
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
        return tmpPixelBounds;
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
            if (index <= this.dataIndexOfCursor) {
                frac = mousePivot * (1.0 -  pow((1.0-(warped/mousePivot)), 1.0/this.mousePower));
            } 
            else {
                frac = mousePivot + (1.0-mousePivot)* pow((warped - mousePivot)/(1.0-mousePivot), 1.0/this.mousePower);
            }
            pix = round(histogramL + frac*histogramW);
        }
        return pix;
    }
  
    //-------------------------------------------------------------
    int pixelToDataIndex (int hpixel) {
  
      float fraca = (float)(hpixel-histogramL)/(float)histogramW;
      fraca = min(1.0f, max(0.0, fraca));
      fraca = warpFraction(fraca, this.mousePower);
  
      float nDataToShowf = (float)(indexHi - indexLo);
      int indexa = indexLo + (int)floor(fraca * nDataToShowf);
      indexa = min(indexHi, max(indexLo, indexa));
      return indexa;
    }
  
    void keyPressed(char k) {
      key = k;
      bKeyPressed = true;
      if (key == 'a') {
        for (int i=0; i<nData; i++) {
          data[i].N += 10;
        }
      } 
      else if (key == 'b') {
        for (int i=0; i<nData; i++) {
          data[i].N -= 10;
        }
      }
    }
  
    //-------------------------------------------------------------
    String dataIndexToDateString (int index) {	
      String out = "";
      if ((index >= 0) && (index < nData)) {
        int monthCount = 0;
        while ( (index > monthStartDays[monthCount]) && (monthCount < 12)) {
          monthCount++;
        }
        monthCount--;
  
        out = dayNames[index%7] + " " + this.monthNames[(monthCount%12)] + " " + (index - monthStartDays[monthCount]);
      }
      return out;
    }
  
    //-------------------------------------------------------------
    void updateHistogramVerticalScale() {
      histogramValueMax       = (float) getMaxDataValueInIndexRange(indexLo, indexHi);
      histogramValueMax       = max(1.0f, histogramValueMax);
      float targetHeight      = (float) histogramH * HISTOGRAM_SPACE_OCCUPANCY;
      histogramValueScaleFactor  = targetHeight / histogramValueMax;
    }
  
    //-------------------------------------------------------------
    final int skipList[]   = {
      1, 5, 10, 25, 50, 100, 250, 500, 1000, 2500, 5000, 10000, 25000, 50000, 100000
    };
    final int skipListSize = skipList.length;
    float FADE_LABEL_TIME  = 333.3;
    int majorLabelSkip     = 100;
    int prevMajorLabelSkip = 250;
    int labelSkipTime      = 0;
    //-------------------------------------------------------------
    // a surprising amount of code is necessary to render the labels correctly.
    void drawHistogramVerticalScale() {
      int now  = (int)System.currentTimeMillis();
  
      // dimension the vertical label.
      int vertL = 0;
      int vertR = histogramL;
      int vertW = vertR - vertL;
      int vertT = histogramT;
      int vertB = histogramB;
      int vertH = histogramH;
      float vertHf = (float)vertH;
      int vertTextT = vertT + 9;
      float keyFontAscent = 8.0;
      float labelDensity = 6;//12.0;
      int charW = 4;
  
      float vertTxCol = CS.vertTxCol;
      float vertLnCol = CS.vertLnCol;
      float vertBgCol = CS.vertBgCol;
  
      // fill the background of the vertical indicator.
      noStroke();
      fill  (vertBgCol);
      rect  (vertL, vertT, vertW, vertH);
  
      // textSpace (OBJECT_SPACE); 
      textFont  (font6, 6);
  
      // hunt for the label that fits.
      int prevMLS = majorLabelSkip;
      majorLabelSkip = max(1, (int)(keyFontAscent*labelDensity/(vertHf/histogramValueMax)));
      int ind = skipListSize-1;
      int skindex = 0;
      float minn = 1000000;
      while (ind >= 0) {
        float fact = (float)skipList[ind]/(float)majorLabelSkip;
        if (abs(fact - 1) < minn) {
          minn = fact;
          skindex = ind;
        }
        ind--;
      }
      skindex = max(0, min(skindex, skipListSize-1));
      majorLabelSkip = skipList[skindex];
      if (prevMLS != majorLabelSkip) {
        prevMajorLabelSkip = prevMLS;
        labelSkipTime = now;
      }
      float spaceSizeMaj  = majorLabelSkip * histogramValueScaleFactor;
      float spaceSizePrev = prevMajorLabelSkip * histogramValueScaleFactor;
  
      // draw the main labels.
      int count;
      int nChars;
      float labelY;
      String labelStr;
      float visibility = (float)(now - labelSkipTime)/FADE_LABEL_TIME; /// 0...->1
      if (visibility < 1.0) {
  
        // fade labels in and out
        float sgr =       visibility*(vertBgCol-vertLnCol)  + vertLnCol;
        float tgr =       visibility*(vertBgCol-vertTxCol)  + vertTxCol;
        float shr = (1.0-visibility)*(vertBgCol-vertLnCol)  + vertLnCol;
        float thr = (1.0-visibility)*(vertBgCol-vertTxCol)  + vertTxCol;
  
        // previous ones
        labelY = vertB - spaceSizePrev; 
        count = 1;
        fill  (tgr, tgr, tgr);
        while (labelY > vertTextT) {
          int labelInt = count*prevMajorLabelSkip;
          if ((labelInt%majorLabelSkip) != 0) {
            int labelYi = (int)round(labelY);
            beginShape(LINES);
            stroke(vertBgCol);
            vertex(0, labelYi);
            stroke(sgr, sgr, sgr);
            vertex(vertR, labelYi);
            endShape();
  
            labelStr = String.valueOf(labelInt);
            nChars = labelStr.length();
            text(labelStr, (vertR-nChars*charW-1), labelYi-2);
          }
          labelY -= spaceSizePrev;
          count++;
        }
  
        // new (current) ones
        labelY = vertB - spaceSizeMaj; 
        count = 1;
        while (labelY > vertTextT) {
          int labelInt = count*majorLabelSkip;
          if ((labelInt%prevMajorLabelSkip) == 0) {
            stroke(vertLnCol);
            fill  (vertTxCol);
          } 
          else {
            stroke(shr, shr, shr);
            fill  (thr, thr, thr);
          }
          int labelYi = (int)round(labelY);
          beginShape(LINES);
          vertex(vertR, labelYi);
          stroke(vertBgCol);
          vertex(0, labelYi);
          endShape();
  
          labelStr = String.valueOf(labelInt);
          nChars = labelStr.length();
          text(labelStr, (vertR-nChars*charW-1), labelYi-2);
          labelY -= spaceSizeMaj;
          count++;
        }
      } 
      else {
        // just draw the labels.
        labelY = vertB - spaceSizeMaj;
        count = 1;
        fill  (vertTxCol);
        while (labelY > vertTextT) {
          int labelYi = (int)round(labelY);
  
          beginShape(LINES);
          stroke(vertBgCol);
          vertex(0, labelYi);
          stroke(vertLnCol);
          vertex(vertR, labelYi);
          endShape();
  
          labelStr = String.valueOf(count*majorLabelSkip);
          nChars = labelStr.length();
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
      var  histTshad = floor (histogramT + 0.5*histogramH);
  
      var  indexa;
      var  indexb; 
      var  indexRange;
      var  nDataToShow = indexHi - indexLo;
      var  rawDataValue;
  
      var  Y;
      var  nDataToShowf = nDataToShow;
      var  nXinv = 1.0/(histogramW);
  
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
        fraca = warpFraction(fraca, this.mousePower);
        fracb = warpFraction(fracb, this.mousePower);
  
        // compute the bounds of the window-of-days
        indexa = indexLo + (int)(fraca * nDataToShowf);
        indexb = indexLo + (int)(fracb * nDataToShowf);
  
        indexa = min(this.nDatam1, max(0, indexa));
        indexb = min(this.nDatam1, max(0, indexb));
        indexRange = (indexb - indexa);
        nonUnaryRange = (indexRange > 1);
  
        //------------------------------------------
        // compute the maximum value within the window-of-days
        var localValueMax = 0;
        if (nonUnaryRange) {
          for (var j=indexa; j<=indexb; j++) {
            rawDataValue = data[j].N;
            if (rawDataValue > localValueMax) {
              localValueMax = rawDataValue;
            }
          }
        } 
        else {
          localValueMax = data[indexa].N;
        }
        Y = histogramB - (localValueMax * histogramValueScaleFactor);
  

  
        evenDay = ((indexa % 2)== 0);
        bandC = (evenDay && (indexRange == 0)) ? band0 : band1;
  
        if (indexa == this.dataIndexOfCursor) {
          dataValueOfCursor = localValueMax;
          tmpPixelBounds[2] = (int)(histogramB - (dataValueOfCursor * histogramValueScaleFactor));
          tmpPixelBounds[3] = histogramB;
  
          //stroke(bandM);
          stroke(bandCurCol);
          line(fixi, histogramB, fixi, Y);
        } 
        else {
          stroke(bandC);
          line(fixi, histogramB, fixi, Y);
        }
        // improve contrast above data
        stroke(bandP);
        point(fixi, Y-1);
      }
    }
  
    //-------------------------------------------------------------
    int getMaxDataValueInIndexRange(int loi, int hii) {
      loi = max(0, min(nDatam1, loi));
      hii = max(0, min(nDatam1, hii));
  
      int maxInRange = 0;
      int rawDataValue = 0;
      for (int i=loi; i<hii; i++) {
        rawDataValue = data[i].N;
        if (rawDataValue > maxInRange) {
          maxInRange = rawDataValue;
        }
      }
      return maxInRange;
    }
  
    //-------------------------------------------------------------
    void loop() {
  
      updateMouseInformation();
      updateHistogramVerticalScale();
      this.dataIndexOfCursor = pixelToDataIndex (floor(mouseXf));
  
      drawBackground();
      drawHistogramData();
      drawCurrentDataBounds();
      drawBands();
      drawOverallFrames();
    }
  
  
  
    //-------------------------------------------------------------
    void drawCurrentDataBounds() {
      cursorToPixelBounds();
  
      var p = tmpPixelBounds[0];
      var q = tmpPixelBounds[1];
      var t = tmpPixelBounds[2];
      centerOfBoundsX = min(q, max(p, centerOfBoundsX));
  
      float A = 0.6f;
      float B = 1.0f-A;
      centerOfBoundsX = A*centerOfBoundsX + B*((p+q)/2.0f);
  
      // stroke(CS.bandMouseColor);
      int bandCurCol = color(curdat_r, curdat_g, curdat_b);
      stroke(bandCurCol);
      line (centerOfBoundsX, t, centerOfBoundsX, histogramT);
  
  
      textMode (MODEL) ;
      textFont (font6, 6);
      fill(bandCurCol); //CS.dateLabelColor); 
      float strY = histogramT+9;
  
      var nbupCh = 0;
      var nbupStr = "";
      if ((dataIndexOfCursor >= 0) && (dataIndexOfCursor < nData)) {
        nbupStr += data[dataIndexOfCursor].N;
        nbupCh  = nbupStr.length();
      }
      var dateString = dataIndexToDateString(dataIndexOfCursor);
  
  
      if ((this.histogramR - centerOfBoundsX) > 52) {
        text(dateString, centerOfBoundsX+4, strY); 
        text(nbupStr, centerOfBoundsX-nbupCh*6+1, strY);
      } 
      else {
        text(dateString, centerOfBoundsX-42, strY); 
        text(nbupStr, centerOfBoundsX+4, strY);
      }
    }
  
    //-------------------------------------------------------------
    void informOfMouse(float x, float y, boolean p) {
        this.bMouseInside = false;
        if ((y >= this.histogramT) && 
            (x <= this.histogramR) && 
            (x >= this.histogramL) && 
            (y <= (this.histogramT + HISTOGRAM_H))) {
  
            bMouseInside = true;
            this.mouseX = min(this.histogramR, x);
    
            if (bUseMouseYMagnification) {
                this.mouseY = y;
            } else {
                this.mouseY = this.histogramT + (this.histogramH * sqrt(0.1));  //0.316..
            }
            this.bMousePressed = p;
            this.hiliteMode = MAUS;
        }
  
        //---------------------------
        if (bMouseInside == false) {

            // hack, use the KOS to obtain a fake mouse position
            var breakupIndex = DUMPSTER_INVALID;
            var moBreakupIndex = KOS.currentMouseoverBreakupId;
            var seBreakupIndex = KOS.currentSelectedBreakupId;

            if (moBreakupIndex != DUMPSTER_INVALID) {
                if (moBreakupIndex == seBreakupIndex) {
                    breakupIndex = seBreakupIndex;
                    this.hiliteMode = SELE;
                } 
                else {
                    breakupIndex = moBreakupIndex;
                    this.hiliteMode = OVER;
                }
            } 
            else {
                if (seBreakupIndex != DUMPSTER_INVALID) {
                    breakupIndex = seBreakupIndex;
                    this.hiliteMode = SELE;
                } 
                else {
                    breakupIndex = DUMPSTER_INVALID;
                    this.hiliteMode = NONE;
                }
            }
  
            if (breakupIndex != DUMPSTER_INVALID) {
                var breakupDate = BM.bups[breakupIndex].date;
                var kosDateFrac = breakupDate / (indexHi-1);
                kosDateFrac = max(0, min(1, kosDateFrac));
        
                this.mouseX = this.histogramL + kosDateFrac*(this.histogramR-this.histogramL);
                this.mouseY = this.histogramT + (histogramH * sqrt(0.1));  //0.316..
            }
        }
  
        switch (hiliteMode) {
            case NONE:
            case MAUS:
                this.curdat_rT = red(CS.bandMouseColor);
                this.curdat_gT = green(CS.bandMouseColor);
                this.curdat_bT = blue(CS.bandMouseColor);
                break;
            case OVER:
                this.curdat_rT = 16;
                this.curdat_gT = 64;
                this.curdat_bT = 255;
                break;
            case SELE:
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
  
      float A = mouseBlur;
      float B = 1.0f - A;
      boolean shiftKeyDown = (bKeyPressed && (key==16));
      boolean ctrlKeyDown  = (bKeyPressed && (key==17));
      if (shiftKeyDown == false) {
        mouseXf = A*mouseXf + B*mouseX;
      }
      if (ctrlKeyDown == false) {
        mouseYf = A*mouseYf + B*mouseY;
      }
  
      if (bUseMouseYMagnification) {
        float fracmy = (float)(mouseYf-histogramT)/(float)histogramH;
        fracmy = min(1.0f, max(0.0f, fracmy));
        fracmy = (float)pow(fracmy, 2.0f);
        this.mousePower = fracmy * 0.75f + 2.0f;
      } 
      else {
        this.mousePower = 2.0f; // thus mousePower is no longer dependent on mouseY;
      }
  
      this.mousePivot = (float)(mouseXf - histogramL)/(float)histogramW;
      this.mousePivot = max(0.0000001f, min(0.999999f, mousePivot));
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
        float oneMpivot = 1-this.mousePivot;
        cube = (frac-this.mousePivot)/(oneMpivot);
        cube = pow (cube, power);
        output  = this.mousePivot + oneMpivot*cube;
      }
      return output;
    }
  
    //-------------------------------------------------------------
    drawBackground() {
      if (true){//bUseBackgroundImage) {
        image(histbgImg, histogramL, histogramT); //
        stroke(255, 200, 200, 24);
        line(histogramL, histogramT+1, histogramR, histogramT+1);
      } 
      else {
        noStroke();
        fill(CS.histogramBackgroundFieldCol);
        rect(histogramL, histogramT, histogramW, histogramH); 
        stroke(255, 200, 200, 24);
        line(histogramL, histogramT+1, histogramR, histogramT+1);
      }
    }
    //-------------------------------------------------------------
    drawBands() {
  
      // draw the scrolling time-axis bands
      for (int i=0; i<nBands; i++) {
        bands[i].render();
        bands[i].drawBoundaries();
      }
  
      // draw labels for the bands
      noStroke();
      fill(0);
      rect(xoffset, yoffset, histogramL, histogramH);
  
      fill(64);
      rect(xoffset, histogramB, histogramL, 10);
  
      fill(128);
      textMode(MODEL);
      textFont(font6, 6);
      text("2005", bands[0].L - 19, bands[0].B - 2);
    }
    //-------------------------------------------------------------
    void drawOverallFrames() {
      stroke(0);
      noFill();
      rect(xoffset, yoffset, width-1, height-1);
      line(histogramL-1, histogramT, histogramL-1, histogramT+height-1);
      line(xoffset, histogramB, histogramL, histogramB);
    }
  



    //-------------------------------------------------------------
    class Band {
  
        constructor (position) {
            this.ID = position;
            this.name = bandNames[ID];
            this.nBoundaries = 0;
        }
  
        setDimensions (l, t, w, h) {
            this.W = w;
            this.H = h;
            this.L = l;
            this.T = t;
            this.R = L+W;
            this.B = T+H;
        }
  
        render() {
            noStroke();//
            fill (CS.bandBgCol);
            rect (this.L, this.T, this.W, this.H);

            stroke(CS.bandEdgeColor);
            noFill();
            rect(this.L-1, this.T, this.W+1, this.H);
        }
  
        //-------------------------------------------------------------
        drawBoundaries() {
            if (nBoundaries > 0) {
    
                var boundaryIndex;
                var boundaryPixel = 0;
                var boundaryPixelPrev = 0;
        
                // compute the locations of the boundary marks,
                // and their distances from one to the next.
                for (var i=1; i<nBoundaries; i++) {
                    // fetch the pre-stored day at which a boundary occurs.
                    boundaryIndex = this.boundaries[i];
        
                    // compute the pixel at which the boundary should be drawn.
                    boundaryPixel   = dataIndexToPixel (boundaryIndex);
                    if (boundaryPixel == -1) {
                        boundaryPixel = histogramR;
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
        
                stroke(CS.vertLnCol);
                textFont(font6);
                textSize(6);
        
                var txC = CS.vertTxCol;
                var bgC = CS.bandBgCol;
                var difC = bgC - txC;
                var minSep = 0;
                var maxSep = 80;
                var texfill;
                var texfrac;
        
                for (var i=0; i<nBoundaries; i++) {
                    sep = this.boundarySeps[i];
                    loc = this.boundaryLocs[i];
                    if ((loc == 0) && (i==0)) loc = histogramL; // WOW big ERROR
        
                    if (i > 0) {
                        line (loc, top, loc, bot);
                    }
        
                    texfrac = max(0, min((sep-minSep), maxSep))/maxSep;
                    texfill = txC + difC*(1.0 - texfrac);
                    fill (0, 0, 0);//texfill);
                    text(this.monthNames[i%12], loc+3, texbot);
                }
            }
        }
  
  
    //-------------------------------------------------------------
    computeBoundaries() {
        // compute the days at which there are scale-specific data boundaries.
        // for example, multiples of 7 for weeks, month-boundaries, and year-boundaries.
        // weeks are the finest level of granularity we care about here.
        var maxPossibleNboundaries = this.nData;
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
        
            //--------------------------
            case 1: // WEEKS
                for (var i=0; i<this.nData; i++) {
                    if (i%7 == 0) {
                    this.boundaries[count] = i;
                    count++;
                    }
                }
                this.nBoundaries = count;
                break;
    
            //--------------------------
            case 0: // MONTHS
                var dayCount = 0;
                var nMos = this.monthLengths2005.length;
                for (var i=0; i<nMos; i++) {
                    dayCount += this.monthLengths2005[i];
                    this.boundaries[count] = dayCount;
                    count++;
                }
                this.nBoundaries = count;
                break;
    
            //--------------------------
            case -1: // YEARS
                for (var i=0; i<this.nData; i++) {
                    if (i%365 == 0) {
                        this.boundaries[count] = i;
                        count++;
                    }
                }
                this.nBoundaries = count;
                break;
            
            //--------------------------
            default:
                break;
        }
    }
    }
}