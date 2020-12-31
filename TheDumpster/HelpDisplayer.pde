import java.applet.*; 
import java.awt.*; 
import java.awt.image.*; 
import java.awt.event.*; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 

public class HelpDisplayer {

  PFont font6;
  String helpStrings[];
  int nHelpStrings;
  int maxNHelpStrings;

  BreakupManager BM;
  KnowerOfSelections KOS;

  final NumberFormat NF = new DecimalFormat("00000");

  float textr;
  float textg;
  float textb;

  float textrT;
  float textgT;
  float textbT; // targets;

  int mode;
  static final int NONE = 0;
  static final int SELE = 1;
  static final int OVER = 2;



  //================================================================
  public HelpDisplayer (PFont foo, BreakupManager bm, KnowerOfSelections kos) {
    font6 = foo;

    BM = bm;
    KOS = kos; 

    nHelpStrings = 0;
    maxNHelpStrings = 10;
    helpStrings = new String[maxNHelpStrings];

    textr = 0;
    textg = 0;
    textb = 0;

    mode = NONE;
  }


  //================================================================
  void update (float mx, float my) {

    mode = NONE;
    int breakupIndex = DUMPSTER_INVALID;
    int moBreakupIndex = KOS.currentMouseoverBreakupId;//currentMouseoverBreakupIdWithOffset;//currentMouseoverBreakupId;
    if (PV.bMouseInView == true) {
      moBreakupIndex = KOS.currentMouseoverBreakupIdWithOffset;
    }

    int seBreakupIndex = KOS.currentSelectedBreakupId;
    if (moBreakupIndex != DUMPSTER_INVALID) {
      if (moBreakupIndex == seBreakupIndex) {
        breakupIndex = seBreakupIndex;
        mode = SELE;
      } 
      else {
        breakupIndex = moBreakupIndex;
        mode = OVER;
      }
    } 
    else {
      if (seBreakupIndex != DUMPSTER_INVALID) {
        breakupIndex = seBreakupIndex;
        mode = SELE;
      } 
      else {
        breakupIndex = DUMPSTER_INVALID;
        mode = NONE;
      }
    }

    switch (mode) {
    case NONE:
      textrT = 0;
      textgT = 0;
      textbT = 0;
      break;
    case OVER:
      textrT = 32;//180;
      textgT = 96;//140;
      textbT = 255;//140;
      break;
    case SELE:
      textrT = 255;
      textgT = 255;
      textbT = 0;
      break;
    }


    helpStrings[0] = getSelectionString (breakupIndex);
    nHelpStrings = 1;
  }

  //================================================================
  void render() {

    textr = HD_TEXT_BLURA*textr + HD_TEXT_BLURB*textrT;
    textg = HD_TEXT_BLURA*textg + HD_TEXT_BLURB*textgT;
    textb = HD_TEXT_BLURA*textb + HD_TEXT_BLURB*textbT;
    fill  (textr, textg, textb);

    textMode(MODEL) ; 
    textFont (font6, 12);

    pushMatrix(); 
    translate (18*9-2, PIXELVIEW_H* PIXELVIEW_SCALE + 25); //DUMPSTER_APP_H - HISTOGRAM_H + 18)); 
    
    int tx = 0;
    int ty = 0;//(int)(DUMPSTER_APP_H - HISTOGRAM_H + 8); //413; 
    for (int i=0; i<nHelpStrings; i++) {
      text(helpStrings[i], 0, ty+0.75f);
      ty += 8;
    }
    
    popMatrix(); 
  }


  //=======================================================================
  String getSelectionString (int breakupIndex) {
    String out = "";


    if ((breakupIndex != DUMPSTER_INVALID) && 
      (breakupIndex >= 0) && 
      (breakupIndex <= N_BREAKUP_DATABASE_RECORDS)) {

      // ID --------------------------------
      int id = BM.bups[breakupIndex].ID;
      String idString = NF.format(id);
      out += "ID: " + idString;
      out += '\n';

      // AGE --------------------------------
      int age = BM.bups[breakupIndex].age;
      out += "AGE: ";
      out += (age > 0) ? (""+age) : "N/A";
      out += '\n';

      // SEX --------------------------------
      int sex = BM.bups[breakupIndex].sex;
      out += "SEX: ";
      switch (sex) {
      case 2: 
        out += "M"; 
        break;
      case 1: 
        out += "F"; 
        break;
      default: 
      case 0: 
        out += "N/A"; 
        break;
      }
      out += '\n';

      // MATCH -------------------------------
      out += "MATCH: ";
      float SIMILARITIES[] = BM.SIMILARITIES;
      int match = (int)(100.0f * SIMILARITIES[breakupIndex]);
      out += match;
      out += '\n';
      
      out += "LENGTH: "; 
      int len = BM.bups[breakupIndex].summaryLen;
      out += "" + len;
      out += '\n';
      
    }

    return out;
  }
}

