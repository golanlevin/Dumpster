
class Paragraph {

  public String myStr;
  public int nLines;
  public int myLeading;

  int startCharIds[];
  boolean b_layoutComputed;

  //static final int charWidths[] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,3,4,6,6,8,7,2,4,4,5,6,3,4,3,5,6,4,6,6,6,6,6,6,6,6,4,4,6,6,6,5,9,7,7,6,7,6,6,7,8,5,5,7,6,9,8,7,6,7,7,7,6,8,7,10,7,7,6,4,5,4,6,6,5,6,6,5,6,6,3,6,6,3,3,6,3,9,6,6,6,6,5,5,3,6,6,9,5,6,5,5,4,5,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,3,6,6,6,7,4,5,5,9,5,6,6,4,9,6,5,6,0,0,5,6,6,3,5,0,5,6,0,0,0,5,7,7,7,7,7,7,10,6,6,6,6,6,5,5,5,5,0,8,7,7,7,7,7,6,7,8,8,8,8,7,0,5,6,6,6,6,6,6,8,5,6,6,6,6,3,3,3,3,0,6,6,6,6,6,6,6,6,6,6,6,6,6,0,6};
  final int charWidths[] = {
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 7, 8, 13, 12, 16, 14, 4, 8, 8, 9, 13, 5, 7, 5, 9, 12, 9, 11, 11, 11, 11, 11, 10, 12, 11, 8, 8, 13, 13, 13, 10, 19, 13, 13, 13, 15, 13, 12, 15, 16, 8, 10, 14, 12, 19, 15, 15, 12, 15, 14, 11, 12, 15, 13, 20, 14, 12, 12, 8, 9, 8, 13, 13, 10, 11, 11, 9, 12, 9, 7, 11, 12, 6, 6, 11, 6, 18, 12, 11, 11, 11, 9, 9, 7, 12, 11, 16, 10, 11, 10, 9, 8, 9, 13, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 7, 11, 12, 11, 12, 8, 10, 10, 19, 10, 12, 13, 7, 19, 12, 8, 13, 0, 0, 10, 11, 10, 6, 10, 0, 10, 12, 0, 0, 0, 10, 13, 13, 13, 13, 13, 13, 19, 13, 13, 13, 13, 13, 8, 8, 8, 8, 0, 15, 15, 15, 15, 15, 15, 13, 15, 15, 15, 15, 15, 12, 0, 11, 11, 11, 11, 11, 11, 11, 15, 9, 9, 9, 9, 9, 6, 6, 6, 6, 0, 12, 11, 11, 11, 11, 11, 13, 11, 12, 12, 12, 12, 11, 0, 11
  };

  static final int   MAX_N_LINES_PER_PARA = 8;
  static final float TEXT_WIDTH_FUDGE_SCALE = 0.5125f; 

  //----------------------------------------
  public Paragraph () {
    startCharIds = new int[MAX_N_LINES_PER_PARA];
    myLeading = 12;
    clear();
  }

  //----------------------------------------
  public void setStringAndComputeLayout(String strg, PFont pF, float maxAllowableWidth) {
    this.clear();
    this.setString(legalizeString(strg));
    this.computeLayout(maxAllowableWidth);
  }

  //----------------------------------------
  public String legalizeString(String strg) {
    int nch = strg.length();
    String outStr = "";

    for (int i=0; i<nch; i++) {
      char c = strg.charAt(i);
      int ci = (int)c;
      if ((ci >= 32) && (c <= 126)) {
        outStr += c;
      }
    }
    return outStr;
  }

  //----------------------------------------
  public void setString (String strg) {
    myStr = strg;
  }

  //----------------------------------------
  public void clear() {
    myStr = "";
    nLines = 0;
    b_layoutComputed = false;
    for (int i=0; i<MAX_N_LINES_PER_PARA; i++) {
      startCharIds[i] = 0;
    }
  }


  //----------------------------------------
  float textWidth (String st) {	
    int nch = st.length();
    float out = 0;
    for (int i=0; i<nch; i++) {
      char c = st.charAt(i);
      out += TEXT_WIDTH_FUDGE_SCALE*(float)(charWidths[(int)c]);
    }
    return out;
  }


  //----------------------------------------
  public void computeLayout (float maxAllowableWidth) {
    // determine the characters at which linebreaks fall, and cache.
    if (myStr != null) {
      int nChars = myStr.length();
      startCharIds[0] = 0;

      float myStrWidth = textWidth(myStr);
      if (myStrWidth < maxAllowableWidth) {
        // String is less than one line long.
        nLines = 1;
      } 
      else {
        // determine where linebreaks fall
        float possibleLineW;
        int startCharId = 0;
        int endCharId   = 0;
        while ( (endCharId < nChars) && (nLines < MAX_N_LINES_PER_PARA)) {
          possibleLineW = 0;
          while ( (possibleLineW <= maxAllowableWidth) && (endCharId < nChars)) {
            endCharId++;
            possibleLineW = textWidth (myStr.substring(startCharId, endCharId));
          } 


          if ((endCharId > 2) && (endCharId < (nChars-2))) {
            char firstCharOfNewLine   = myStr.charAt(endCharId    );
            char secondCharOfNewLine  = myStr.charAt(endCharId + 1);
            char lastCharOfPrevLine   = myStr.charAt(endCharId - 1);
            char penultCharOfPrevLine = myStr.charAt(endCharId - 2);
            if ((lastCharOfPrevLine != ' ') && (firstCharOfNewLine != ' ') && isSpaceOrPunctuation(secondCharOfNewLine)) {
              endCharId += 2; // Prevent orphans: lines which start on the last character of a word.
            } 
            else if (isSpaceOrPunctuation(penultCharOfPrevLine) && (lastCharOfPrevLine != ' ') && (firstCharOfNewLine != ' ')) {
              endCharId--; // Prevent widows: lines which end on the first char of a new word.
            }
            while ( (endCharId < (nChars-2)) && (myStr.charAt(endCharId) == ' ')) {
              endCharId++;  // Prevent spurious indents
            }
          }


          nLines++;
          if (nLines < MAX_N_LINES_PER_PARA) {
            startCharIds[nLines] = endCharId;
            startCharId = endCharId;
          }
        }
      }
      b_layoutComputed = true;
    }
  }

  //----------------------------------------
  boolean isSpaceOrPunctuation (char c) {
    boolean out = false;
    if ((c == ' ') || (c == '.') || (c == ',') || (c == '!') || (c == '?') || (c == ':')) {
      out = true;
    }
    return out;
  }

  //----------------------------------------
  public void render (float x, float y) {
    if (b_layoutComputed) {
      float textX = x;
      float textY = y;

      if (nLines == 1) {
        text (myStr, textX, textY);
      } 
      else { 
        int nChars = myStr.length();
        int startChar = startCharIds[0];
        int endChar = startChar;
        int nLinesSafe = Math.min(nLines, MAX_N_LINES_PER_PARA-1);
        final float maxTextY = HEART_WALL_B + 6;


        for (int i=0; i<nLinesSafe; i++) {
          endChar = startCharIds[i+1];
          if ((startChar>=0) && (startChar<nChars) && (startChar <=endChar) &&
            (endChar  >=0) && (endChar <=nChars)) {
            if (textY <= maxTextY) {
              text (myStr.substring(startChar, endChar), textX, textY);
            }
            textY += myLeading;
            startChar = endChar;
          }
        }
      }
    }
  }
}

