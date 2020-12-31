//-------------------------------------------------------------
class HistogramColorScheme {


  color histogramBackgroundColor0;
  color histogramBackgroundColor1;
  color histogramBackgroundColor2;
  color histogramBackgroundColor3;

  color histogramBackgroundColor1s;
  color histogramBackgroundColor2s;
  color histogramBackgroundColor3s;

  color histogramBackgroundFieldCol;

  color bandEdgeColor;
  color bandFillColor0;
  color bandFillColor1;
  color bandFillColor2;
  color bandCapColor;
  color bandMouseColor;
  color bandTextColor;
  color bandBoundaryColor;
  color dateLabelColor;

  float bandBgCol = 160;
  float vertTxCol = 16;
  float vertLnCol = 108;
  float vertBgCol = 144;

  public HistogramColorScheme () {
 

    bandEdgeColor     = color(0, 0, 0);
    bandFillColor0    = color(148, 71, 66); //13, 72, 201); //255,206,172);//255,208,208);
    bandFillColor1    = color(112, 52, 47); //6,  49, 154); //193,155,128);//215,189,189);
    bandFillColor2    = color(17, 7, 7);  //0,  38, 106); //133,120,111);//185,176,176);
    bandCapColor      = color(0, 0, 0);
    bandMouseColor    = color(255, 38, 46);//252,38, 46); //255,100,0);//0,144,255);//255,100,0);//255,0,0);
    bandTextColor     = color(0, 0, 0);
    bandBoundaryColor = color(144, 128, 128);
    dateLabelColor    = color(148, 71, 66);

    histogramBackgroundColor0 = color(0, 0, 0);
    histogramBackgroundColor1 = color(32, 32, 32);
    histogramBackgroundColor2 = color(16, 16, 16);
    histogramBackgroundColor3 = color(24, 24, 24);

    histogramBackgroundColor1s = color(64, 64, 64);//20,20,20);
    histogramBackgroundColor2s = color(64, 64, 64);// 4, 4, 4);
    histogramBackgroundColor3s = color(12, 12, 12);

    histogramBackgroundFieldCol = color(39, 19, 19);//0, 42, 58);
  }
}

