

class DumpsterHistogram {

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

  //-------------------------------------------------------------
  DumpsterHistogram (PFont foo, float x, float y, float w, float h, KnowerOfSelections kos) {
    KOS 	 = kos; 

    bMouseInside = false;
    hiliteMode = 0;

    width  = (int)w;
    height = (int)h;
    xoffset = (int)x;
    yoffset = (int)y;

    font6 = foo;

    setup();
  }


  //-------------------------------------------------------------
  void setup() {

    CS = new HistogramColorScheme();
    mouseXf = 0;
    mouseYf = 0;

    bUseMouseYMagnification = true;


    bUseBogusData = false;
    if (bUseBogusData) {

      int I = 0;
      nData = 365;
      nDatam1 = nData-1;
      data = new HistogramDatum[nData];
      for (int i=0; i<nData; i++) {
        int N = (int)round(130.0f * (0.2f + random(0, 1)*0.8f));
        data[i] = new HistogramDatum(I, N);
        I++;
      }
      indexLo = 0;
      indexHi = 364;
    } 
    else {
      String lines[] = loadStrings("breakupsPerDay2005.txt");
      int nFileLines = lines.length;
      nData = nFileLines;
      nDatam1 = nData-1;

      int I = 0;
      data = new HistogramDatum[nData];
      for (int i=0; i < nDatam1; i++) {
        int N = Integer.parseInt(lines[i+1]);
        data[i] = new HistogramDatum(I, N);
        I++;
      } 
      data[nDatam1] = new HistogramDatum(I, 0);
      indexLo = 0;
      indexHi = nData-1;
    }



    nBands     = 1;
    bandH      = 10;

    histogramL = xoffset + (int)HEART_WALL_L;
    histogramR = xoffset + width - 1;
    histogramW = histogramR - histogramL;
    histogramT = yoffset + 0;
    histogramB = yoffset + ((height+1)-2 - (nBands*bandH));
    histogramH = histogramB - histogramT;
    histogramValueScaleFactor = 1.0f;

    tmpPixelBounds = new int[4];
    tmpPixelBounds[0] = 0;//L
    tmpPixelBounds[1] = 0;//R
    tmpPixelBounds[2] = 0;//T
    tmpPixelBounds[3] = 0;//B

    bands = new Band[nBands];
    for (int i=0; i<nBands; i++) {
      bands[i] = new Band(i);
      bands[i].setDimensions (histogramL, (DUMPSTER_APP_H-1 - (nBands*bandH)) + (bandH*i), histogramW, bandH);
      bands[i].computeBoundaries();
    }



    bUseBackgroundImage = true;
    if (bUseBackgroundImage) {
      switch ((int)DUMPSTER_APP_W){
        
        case 1280:  
          histbg = loadImage ("hist_1010x125.jpg");
          // histbg = loadImage ("hist_980x120.jpg");
          break;
          
        case 1024: 
          histbg = loadImage ("hist_972x67.jpg");
          break;
          
        default:
        case 640:
          histbg = loadImage ("hist_587x67.jpg");
      }
      
    } 
    else {
      histbg = null;
    }

    monthStartDays = new int[13];
    int count = -1; 
    for (int i=0; i<13; i++) {
      monthStartDays[i] = count;
      count += monthLengths2005[i+1];
    }
  }


  //-------------------------------------------------------------
  int[] cursorToPixelBounds() {
    // search downward and upward from the cursor pixel,
    // whose data index we (are required to) also know.

    int mouseXi = (int)mouseXf;
    mouseXi = max(histogramL, min(histogramR-1, mouseXi));

    float fraca, fracb;
    int indexa = 0;
    int indexb = 0;
    int pixela = -1;
    int pixelb = -1;

    pixela = dataIndexToPixel(dataIndexOfCursor);
    if ((dataIndexOfCursor < (indexHi-1)) && (mouseXi < (histogramR-1))) {
      pixelb = dataIndexToPixel(dataIndexOfCursor+1);
    } 
    else {
      pixelb = histogramR-1;
    }
    // patch a problem which appears in highly compressed situations.
    if (pixelb < pixela) {
      pixelb = pixela;
    }

    // note that tmpPixelBounds[2] and [3] are set in drawHistogramData().
    tmpPixelBounds[0] = pixela;
    tmpPixelBounds[1] = pixelb;
    return tmpPixelBounds;
  }

  //-------------------------------------------------------------
  // inverse warping yields two results:
  // frac = mousePivot * (1.0 - pow((1.0-(warped/mousePivot)), 1.0/mousePower));
  // frac = mousePivot + (1.0-mousePivot)*pow((warped - mousePivot)/(1.0-mousePivot), 1.0/mousePower);
  int dataIndexToPixel (int index) {
    int pix = -1;
    float frac = 0.5f;
    if ((index >= indexLo) && (index < indexHi)) {
      float warped = (float)(index - indexLo)/(float)(indexHi - indexLo);
      if (index <= dataIndexOfCursor) {
        frac = mousePivot * (1.0f -  (float)pow((1.0f-(warped/mousePivot)), 1.0f/mousePower));
      } 
      else {
        frac = mousePivot + (1.0f-mousePivot)* (float)pow((warped - mousePivot)/(1.0f-mousePivot), 1.0f/mousePower);
      }
      pix = (int)round(histogramL + frac*histogramW);
    }
    return pix;
  }

  //-------------------------------------------------------------
  int pixelToDataIndex (int hpixel) {

    float fraca = (float)(hpixel-histogramL)/(float)histogramW;
    fraca = min(1.0f, max(0.0f, fraca));
    fraca = warpFraction(fraca, mousePower);

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

      out = dayNames[index%7] + " " + monthNames[(monthCount%12)] + " " + (index - monthStartDays[monthCount]);
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
  float FADE_LABEL_TIME  = 333.3f;
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
    float keyFontAscent = 8.0f;
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
    if (visibility < 1.0f) {

      // fade labels in and out
      float sgr =       visibility*(vertBgCol-vertLnCol)  + vertLnCol;
      float tgr =       visibility*(vertBgCol-vertTxCol)  + vertTxCol;
      float shr = (1.0f-visibility)*(vertBgCol-vertLnCol)  + vertLnCol;
      float thr = (1.0f-visibility)*(vertBgCol-vertTxCol)  + vertTxCol;

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
  void drawHistogramData() {
    // noSmooth();

    float fraca, fracb;
    boolean evenWeek, evenDay;
    boolean nonUnaryRange = false;
    int histTshad = (int)(histogramT + 0.5f*histogramH);

    int indexa, indexb, indexRange;
    int nDataToShow = indexHi - indexLo;
    int rawDataValue;

    float Y;
    final float nDataToShowf = (float)nDataToShow;
    final float nXinv = 1.0f/(float)(histogramW);

    int band0 = CS.bandFillColor0;
    int band1 = CS.bandFillColor1;
    int band2 = CS.bandFillColor2;
    int bandM = CS.bandMouseColor;
    int bandP = CS.bandCapColor;
    int bandC;

    int week1 = CS.histogramBackgroundColor1;
    int week2 = CS.histogramBackgroundColor2;
    int week3 = CS.histogramBackgroundColor3;
    int weekC;

    int week1s = CS.histogramBackgroundColor1s;
    int week2s = CS.histogramBackgroundColor2s;
    int week3s = CS.histogramBackgroundColor3s;
    int weekS;

    int histbgCol = CS.histogramBackgroundFieldCol;

    float fixi;
    int bandCurCol = color(curdat_r, curdat_g, curdat_b);


  
    //------------------------------------------
    // for each pixel across the histogram
    for (int i=histogramL; i<histogramR; i++) {
      fixi = i+0.5f;

      fraca = (float)(i  -histogramL)*nXinv;
      fracb = (float)(i+1-histogramL)*nXinv;

      // non-linearize the view
      fraca = warpFraction(fraca, mousePower);
      fracb = warpFraction(fracb, mousePower);

      // compute the bounds of the window-of-days
      indexa = indexLo + (int)(fraca * nDataToShowf);
      indexb = indexLo + (int)(fracb * nDataToShowf);

      indexa = min(nDatam1, max(0, indexa));
      indexb = min(nDatam1, max(0, indexb));
      indexRange = (indexb - indexa);
      nonUnaryRange = (indexRange > 1);

      //------------------------------------------
      // compute the maximum value within the window-of-days
      float localValueMax = 0;
      if (nonUnaryRange) {
        for (int j=indexa; j<=indexb; j++) {
          rawDataValue = data[j].N;
          if (rawDataValue > localValueMax) {
            localValueMax = (float) rawDataValue;
          }
        }
      } 
      else {
        localValueMax =  (float) data[indexa].N;
      }
      Y = histogramB - (localValueMax * histogramValueScaleFactor);


      //------------------------------------------
      // draw the week-colored background.
      /*
    if (indexRange > 2){
       weekC = week3;
       weekS = week3s;
       } else {
       evenWeek = (((indexa/7)%2)== 0);
       weekC = (evenWeek) ? week1  : week2;
       weekS = (evenWeek) ? week1s : week2s;
       }
       stroke(weekC);
       line(fixi, Y, fixi, histTshad);
       */

      /*
    //------------------------------------------
       // drop-shadow...
       beginShape(LINES); 
       vertex(fixi, histTshad);
       stroke(weekS);
       vertex(fixi, histogramT);
       endShape();
       */

      /*
    // draw the main background color, 
       // but do it by drawing lines.
       stroke(histbgCol);
       line(fixi, Y, fixi, histogramT);
       */


      //------------------------------------------
      // day: select the color based on the density, index, and cursor
      /*
    if (nonUnaryRange){
       bandC = band2;
       } else {
       evenDay = ((indexa % 2)== 0);
       bandC = (evenDay && (indexRange == 0)) ? band0 : band1;
       }
       */

      evenDay = ((indexa % 2)== 0);
      bandC = (evenDay && (indexRange == 0)) ? band0 : band1;

      if (indexa == dataIndexOfCursor) {
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
    dataIndexOfCursor = pixelToDataIndex ((int)mouseXf);

    drawBackground();
    drawHistogramData();
    drawCurrentDataBounds();
    drawBands();
    drawOverallFrames();
  }



  //-------------------------------------------------------------
  void drawCurrentDataBounds() {
    cursorToPixelBounds();


    int p = tmpPixelBounds[0];
    int q = tmpPixelBounds[1];
    int t = tmpPixelBounds[2];
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

    int nbupCh = 0;
    String nbupStr = "";
    if ((dataIndexOfCursor >= 0) && (dataIndexOfCursor < nData)) {
      nbupStr += data[dataIndexOfCursor].N;
      nbupCh  = nbupStr.length();
    }
    String dateString = dataIndexToDateString(dataIndexOfCursor);


    if ((histogramR - centerOfBoundsX) > 52) {
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
    bMouseInside = false;

    if ((y >= histogramT) && (x <= histogramR) && (x >= histogramL) && (y <= (histogramT + HISTOGRAM_H))) {

      bMouseInside = true;
      mouseX = min(histogramR, x);

      if (bUseMouseYMagnification) {
        mouseY = y;
      } 
      else {
        mouseY = histogramT + (histogramH * (float)sqrt(0.1f));  //0.316..
      }
      bMousePressed = p;
      hiliteMode = MAUS;
    }

    //---------------------------
    if (bMouseInside == false) {
      // hack, use the KOS to obtain a fake mouse position


      int breakupIndex = DUMPSTER_INVALID;
      int moBreakupIndex = KOS.currentMouseoverBreakupId;
      int seBreakupIndex = KOS.currentSelectedBreakupId;
      if (moBreakupIndex != DUMPSTER_INVALID) {
        if (moBreakupIndex == seBreakupIndex) {
          breakupIndex = seBreakupIndex;
          hiliteMode = SELE;
        } 
        else {
          breakupIndex = moBreakupIndex;
          hiliteMode = OVER;
        }
      } 
      else {
        if (seBreakupIndex != DUMPSTER_INVALID) {
          breakupIndex = seBreakupIndex;
          hiliteMode = SELE;
        } 
        else {
          breakupIndex = DUMPSTER_INVALID;
          hiliteMode = NONE;
        }
      }

      if (breakupIndex != DUMPSTER_INVALID) {
        int breakupDate = BM.bups[breakupIndex].date;

        float kosDateFrac = (float) breakupDate / (float)(indexHi-1);
        kosDateFrac = max(0, min(1, kosDateFrac));

        mouseX = histogramL + kosDateFrac*(histogramR-histogramL);
        mouseY = histogramT + (histogramH * (float)sqrt(0.1f));  //0.316..
      }
    }


    switch (hiliteMode) {
    case NONE:
    case MAUS:
      curdat_rT = red(CS.bandMouseColor);
      curdat_gT = green(CS.bandMouseColor);
      curdat_bT = blue(CS.bandMouseColor);
      break;
    case OVER:
      curdat_rT = 16;
      curdat_gT = 64;
      curdat_bT = 255;
      break;
    case SELE:
      curdat_rT = 255;
      curdat_gT = 255;
      curdat_bT = 0;
      break;
    }



    curdat_r = DH_BLURA*curdat_r  + DH_BLURB*curdat_rT;
    curdat_g = DH_BLURA*curdat_g  + DH_BLURB*curdat_gT;
    curdat_b = DH_BLURA*curdat_b  + DH_BLURB*curdat_bT;
  }
  //-------------------------------------------------------------
  void updateMouseInformation() {

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
      mousePower = fracmy * 0.75f + 2.0f;
    } 
    else {
      mousePower = 2.0f; // thus mousePower is no longer dependent on mouseY;
    }

    mousePivot = (float)(mouseXf - histogramL)/(float)histogramW;
    mousePivot = max(0.0000001f, min(0.999999f, mousePivot));
  }

  //-------------------------------------------------------------------
  float warpFraction (float frac, float power) {
    float output = frac;
    float cube;

    if (frac <= mousePivot) {
      cube = 1 - (frac/mousePivot);
      cube = (float)pow (cube, power);
      output  = mousePivot * (1-cube);
    } 
    else {
      float oneMpivot = 1-mousePivot;
      cube = (frac-mousePivot)/(oneMpivot);
      cube = (float)pow (cube, power);
      output  = mousePivot + oneMpivot*cube;
    }
    return output;
  }

  //-------------------------------------------------------------
  void drawBackground() {
    if (bUseBackgroundImage) {
      image(histbg, histogramL, histogramT); //
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
  void drawBands() {

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

    float L, R;
    float T, B;
    float W, H;
    String name;
    int ID;

    int boundaries[];   // data indexes
    int boundaryLocs[]; // pixel locations
    int boundarySeps[]; // pixel separations

    int nBoundaries;

    float daysPerPixel = 1.0f;

    Band (int position) {
      ID = position;
      name = bandNames[ID];
      nBoundaries = 0;
    }

    void setDimensions (float l, float t, float w, float h) {
      W = w;
      H = h;
      L = l;
      T = t;
      R = L+W;
      B = T+H;
    }

    void render() {
      noStroke();//
      fill  (CS.bandBgCol);
      rect(L, T, W, H);

      stroke(CS.bandEdgeColor);
      noFill();
      rect(L-1, T, W+1, H);
    }

    //-------------------------------------------------------------
    void drawBoundaries() {
      if (nBoundaries > 0) {

        int boundaryIndex;
        int boundaryPixel = 0;
        int boundaryPixelPrev = 0;
        int separation;

        // compute the locations of the boundary marks,
        // and their distances from one to the next.
        for (int i=1; i<nBoundaries; i++) {
          // fetch the pre-stored day at which a boundary occurs.
          boundaryIndex = boundaries[i];

          // compute the pixel at which the boundary should be drawn.
          boundaryPixel   = dataIndexToPixel (boundaryIndex);
          if (boundaryPixel == -1) {
            boundaryPixel = histogramR;
          } 

          boundaryLocs[i]   = boundaryPixel;
          boundarySeps[i-1] = boundaryPixel - boundaryPixelPrev;
          boundaryPixelPrev = boundaryPixel;
        }
        int sep = 0;
        int loc = 0;
        int top = (int)T+1;
        int bot = (int)B-1;
        int mid = (top+bot)/2;
        int texbot = bot-1;

        stroke(CS.vertLnCol);
        textMode(MODEL); 
        textFont(font6, 6);

        float txC = CS.vertTxCol;
        float bgC = CS.bandBgCol;
        float difC = bgC - txC;
        float minSep = 0;
        float maxSep = 80;
        float texfill;
        float texfrac;

        for (int i=0; i<nBoundaries; i++) {
          sep = boundarySeps[i];

          loc = boundaryLocs[i];
          if ((loc == 0) && (i==0)) loc = histogramL; // WOW big ERROR

          if (i > 0) {
            line (loc, top, loc, bot);
          }

          texfrac = max(0, min((sep-minSep), maxSep))/maxSep;
          texfill = txC + difC*(1.0f - texfrac);
          fill (0, 0, 0);//texfill);
          text(monthNames[i%12], loc+3, texbot);
        }
      }
    }


    //-------------------------------------------------------------
    void computeBoundaries() {
      // compute the days at which there are scale-specific data boundaries.
      // for example, multiples of 7 for weeks, month-boundaries, and year-boundaries.
      // weeks are the finest level of granularity we care about here.
      int maxPossibleNboundaries = nData;
      boundaries   = new int[maxPossibleNboundaries];
      boundaryLocs = new int[maxPossibleNboundaries];
      boundarySeps = new int[maxPossibleNboundaries];
      nBoundaries = 0;

      int count = 0;
      switch(ID) {
        //--------------------------
      case 1: // WEEKS
        for (int i=0; i<nData; i++) {
          if (i%7 == 0) {
            boundaries[count] = i;
            count++;
          }
        }
        nBoundaries = count;
        break;

        //--------------------------
      case 0: // MONTHS
        int dayCount = 0;
        int nMos = monthLengths2005.length;
        for (int i=0; i<nMos; i++) {
          dayCount += monthLengths2005[i];
          boundaries[count] = dayCount;
          count++;
        }
        nBoundaries = count;
        break;

        //--------------------------
      case -1: // YEARS
        for (int i=0; i<nData; i++) {
          if (i%365 == 0) {
            boundaries[count] = i;
            count++;
          }
        }
        nBoundaries = count;
        break;

      default:
        break;
      }
    }
  }
}
