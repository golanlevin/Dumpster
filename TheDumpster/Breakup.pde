class Breakup {

  int ID; // 0....20000

  int age;
  int sex;
  int date;
  int fault;
  int instigator;
  int summaryLen;
  int nBitsSet;
  float langMetric;

  float languageData[];
  int 	languageTags[];
  int 	kamalTags;
  int 	accessTags;

  boolean b_normalizeByStdvs;
  boolean bIdValid = false;
  boolean VALID; 

  float distanceFromCurrBupByLanguage;
  float heartRadius;


  int bitValues[] = new int[32];
  final float langTagRelativeValues[] = { 0.80f, 1.00f, 0.50f, 0.40f };

  float NBITSPOW  = (float)( Math.log(0.5) / Math.log(3.97/16.0) );
  float NLENPOW   = (float)( Math.log(0.5) / Math.log(171.0f/255.0f) );

  //=============================================================
  Breakup (int id) {

    VALID = true;
    if ((id >= 0) && (id < N_BREAKUP_DATABASE_RECORDS)) {
      bIdValid = true;
    }

    ID = id;
    age = 0;
    sex = 0;
    date = 0;
    heartRadius = HEART_AVG_RAD;

    languageData = new float[N_BREAKUP_LANGUAGE_DESCRIPTORS];
    for (int i=0; i<N_BREAKUP_LANGUAGE_DESCRIPTORS; i++) {
      languageData[i] = 0.0f;
    }
    languageTags = new int[N_BREAKUP_LANGUAGE_BITFLAGS];
    for (int i=0; i<N_BREAKUP_LANGUAGE_BITFLAGS; i++) {
      languageTags[i] = 0;
    }

    b_normalizeByStdvs = false;
    distanceFromCurrBupByLanguage = 0.0f;
    langMetric = 0;

    for (int i=0; i<32; i++) {
      bitValues[i] = 1<<i;
    }
  }

  //=============================================================
  int compareTo (Breakup BR, int method) {

    int out = 0;
    switch (method) {
    default:
    case BUP_COMPARE_AGE:
      if (BR.age < age) {
        out = -1;
      } 
      else if (BR.age == age) {
        out = 0;
      } 
      else {
        out = 1;
      }
      break;

    case BUP_COMPARE_SEX:
      if (BR.sex < sex) {
        out = -1;
      } 
      else if (BR.sex == sex) {
        out = 0;
      } 
      else {
        out = 1;
      }
      break;

    case BUP_COMPARE_INSTIG:
      if (BR.instigator < instigator) {
        out = -1;
      } 
      else if (BR.instigator == instigator) {
        out = 0;
      } 
      else {
        out = 1;
      }
      break; 

    case BUP_COMPARE_LANG:
      if (BR.langMetric < langMetric) {
        out = 1;
      } 
      else if (BR.langMetric == langMetric) {
        out = 0;
      } 
      else {
        out = -1;
      }
      break;
    }

    return out;
  }




  //=============================================================
  void setAccessTags (int good, int gen, int flt, int instig, int themes) {
    VALID 		= (good > 0) ? true : false;
    sex 			= gen;
    fault 		= flt;
    instigator 	= instig;
    accessTags 	= themes;
  }

  //=============================================================
  void setKamalFlags (int a, int d, int kt) {
    age 	= a;
    date 	= d;
    kamalTags = kt;
  }

  //=============================================================
  void setLanguageTags (int dat[]) {
    for (int i=0; i<N_BREAKUP_LANGUAGE_BITFLAGS; i++) {
      languageTags[i] = dat[i];
    }
  }

  //=============================================================
  void setLanguageData (float dat[]) {
    for (int i=0; i<N_BREAKUP_LANGUAGE_DESCRIPTORS; i++) {
      languageData[i] = dat[i];
    }

    if (b_normalizeByStdvs) {
      for (int i=0; i<N_BREAKUP_LANGUAGE_DESCRIPTORS; i++) {
        languageData[i] -= LANG_MEANS[i];
        languageData[i] /= LANG_STDVS[i];
      }
    }
  }

  void setSummaryLength(int slen) {
    summaryLen = slen;

    float fuk = languageData[2];
    float cap = languageData[3];
    float exc = languageData[4];
    langMetric = slen/255.0f + fuk + cap;
  }



  /*
	
   float f1 = bups[i].ego_normalized; // ego centrism, 0..1
   float f2 = bups[i].exo_normalized; // exo centrism, 0..1
   float f3 = bups[i].fuk_normalized; // foul mouthedness, 0..1
   float f4 = bups[i].cap_normalized; // capitalizingness, 0..1
   float f5 = bups[i].exc_normalized; // exclamationness, 0..1
   float f6 = bups[i].que_normalized; // questioningness, 0..1
   float f7 = bups[i].per_normalized; // periodness, 0..1
   */


  //=============================================================
  int computeNBitsSet() {

    int n = 0;

    if (age > 0) 			n++;
    if (sex > 0) 			n++;
    if (fault > 0) 		n++;
    if (instigator > 0)	n++;

    for (int b=0; b<32; b++) {
      if ((kamalTags  & bitValues[b]) > 0) n++;
      if ((accessTags & bitValues[b]) > 0) n++;
      for (int j=0; j<N_BREAKUP_LANGUAGE_BITFLAGS; j++) {
        if ((languageTags[j] & bitValues[b]) > 0) n++;
      }
    }

    nBitsSet = n;
    return nBitsSet;
  }



  //=============================================================
  void computeHeartRadius() {
    // given the nBitsSet, which ranges from 0..16 with average 3.97, 
    // given the summaryLen, which ranges from 0(3)..255 with average 171,
    // determine the radius of my heart. 

    float maxBitsSetf = 12; //CLAMPING: actually, 16 empirical
    float nBitsFrac = Math.min(1.0f, (float)nBitsSet/maxBitsSetf); 
    nBitsFrac = (float) (Math.pow(nBitsFrac, NBITSPOW)); 

    float maxSummaryLen = 230; //CLAMPING: actually 255 empirical
    float nLenFrac = Math.min(1.0f, (float)summaryLen/maxSummaryLen);
    nLenFrac = (float) (Math.pow(nLenFrac, NLENPOW)); 

    // now both nBitsFrac and nLenFrac vary between 0..1, 
    // and have collection averages centered on 0.5.
    // create a weighted mixture of the two properties. 
    float radiusFrac = (0.25f*nBitsFrac) + (0.75f*nLenFrac);
    radiusFrac  = (float)Math.pow(radiusFrac, 2.75f); 
    heartRadius =  HEART_MIN_RAD + radiusFrac*(HEART_MAX_RAD - HEART_MIN_RAD);
  }


  //=============================================================
  float computeLanguageDistance (float otherLanguageData[]) {

    float dval;
    float dist = 0.0f;

    for (int i=0; i<N_BREAKUP_LANGUAGE_DESCRIPTORS; i++) {
      dval = (languageData[i] - otherLanguageData[i]);
      dist += dval*dval;
    }
    dist = (float)Math.sqrt(dist);
    distanceFromCurrBupByLanguage = dist;
    return dist;
  }

  //=============================================================
  float computeLanguageTagNCommonalities (int otherTags[]) {

    float nScaledCommonProperties = 0;
    for (int i=0; i<N_BREAKUP_LANGUAGE_BITFLAGS; i++) {
      int commonProperties = (languageTags[i] & otherTags[i]); 

      for (int b=0; b<32; b++) {
        if ((commonProperties & bitValues[b]) > 0) {
          nScaledCommonProperties += langTagRelativeValues[i];
        }
      }
    }
    return nScaledCommonProperties;
  }

  //=============================================================
  float computeKamalTagCommonalities (int otherKTags) {

    float nCommonProperties = 0;
    int commonProperties = (kamalTags & otherKTags); 
    for (int b=0; b<32; b++) {
      if ((commonProperties & bitValues[b]) > 0) {
        nCommonProperties ++;
      }
    }
    return nCommonProperties;
  }

  //=============================================================
  float computeAccessTagCommonalities (int otherSex, int otherFault, int otherInstigator, int otherAccessTags) {

    float nCommonProperties = 0;

    nCommonProperties += (sex & otherSex);
    nCommonProperties += (fault & otherFault);
    nCommonProperties += (instigator & otherInstigator); 

    int commonProperties = (accessTags & otherAccessTags); 
    for (int b=0; b<10; b++) {
      if ((commonProperties & bitValues[b]) > 0) {
        nCommonProperties ++;
      }
    }
    return nCommonProperties;
  }

  //=============================================================
  float computeAgeDifference (int otherAge) {
    float out = 0;
    if ((age != 0) && (otherAge != 0)) {
      out = (float) Math.abs (age - otherAge);
    } 
    else {
      out = DUMPSTER_INVALID;
    }
    return out;
  }


  //=============================================================
}	





//---------------------------------------------------------
/*
LANGUAGE FLOATS
 
 float f1 = bups[i].ego_normalized; // ego centrism, 0..1
 float f2 = bups[i].exo_normalized; // exo centrism, 0..1
 float f3 = bups[i].fuk_normalized; // foul mouthedness, 0..1
 float f4 = bups[i].cap_normalized; // capitalizingness, 0..1
 float f5 = bups[i].exc_normalized; // exclamationness, 0..1
 float f6 = bups[i].que_normalized; // questioningness, 0..1
 float f7 = bups[i].per_normalized; // periodness, 0..1
 */
//---------------------------------------------------------
/*
LANGUAGE TAGS
 	
 String kidWords1[] = {
 " suck", " fuck", " shit", " stupid", " bitch",  "sux", " crap", " ass ", " asshole", " bull", " slut",  " whore", " dick" , " puss", " cock", " cunt", " boobs" };
 
 String kidWords2[] = {
 " comment", " hate", " bor", " hot", " gay", " kiss", " emo", " sex ", " pot",  " smok", " lying", " liar", " married",  " lesbian", " weed", " abortion"};
 
 String kidWords3[] = {
 " u ", " lol ", " cuz ", " w/", " n ", " g2g", " 4 ", " omg", " bf ", " ttyl",  " idk ", "b/c", " gf ", " gurl",  " bc ", " b/f", " kool", " gtg", " g/f", " jk ", " j/k", " n2mh", " b4 ", " guyz", " idc ", " omfg", " nvm", " yo ", "ommfg",  "t2yl"};
 
 String kidWords4[] = {
 " wit ", " sooo", " ppl", " luv", " lil ", " w/e ", " skool", " sry", "peep", "neways", " buh", " waz ", " wtf",  " wuz ", " lyl ",   " kewl", "some1", "4ever", " afta ", " wif ", " lik ",  "l8r", "l8er", " nm ", "newayz", " wth ", "l8ly", " wb ", " luzer"};
 */

/*
KAMAL TAGS
 
 FLAGSTRINGS[i++] = "Emotional Reaction::Anger";          //1809
 FLAGSTRINGS[i++] = "Emotional Reaction::Sad";            //1624
 FLAGSTRINGS[i++] = "Emotional Reaction::Cried";          //1092
 FLAGSTRINGS[i++] = "Emotional Reaction::Acceptance";     //1019
 FLAGSTRINGS[i++] = "Emotional Reaction::Excitement";     //897
 FLAGSTRINGS[i++] = "Other::Want to be Friends";          //870
 FLAGSTRINGS[i++] = "Emotional Reaction::Im Single";      //672
 FLAGSTRINGS[i++] = "Other::Multiple breakups";           //617
 FLAGSTRINGS[i++] = "Emotional Reaction::Upset";          //417
 FLAGSTRINGS[i++] = "Breakup Factors::Cheating";          //315
 FLAGSTRINGS[i++] = "Emotional Reaction::Depression";     //279
 FLAGSTRINGS[i++] = "Emotional Reaction::Missing Partner";//269
 FLAGSTRINGS[i++] = "Breakup Factors::Moving";            //149
 FLAGSTRINGS[i++] = "Emotional Reaction::Denial";         //131
 FLAGSTRINGS[i++] = "Emotional Reaction::Heartbroken";    //125
 FLAGSTRINGS[i++] = "Other::Drugs";                       //106
 FLAGSTRINGS[i++] = "Breakup Factors::Taking a break";    //100
 FLAGSTRINGS[i++] = "Other::Alcohol";                     //85
 FLAGSTRINGS[i++] = "Emotional Reaction::Worst Day of Author's Life";//83
 FLAGSTRINGS[i++] = "Other::Sex";                         //78
 FLAGSTRINGS[i++] = "Other::Hoping for Reunion";          //55
 FLAGSTRINGS[i++] = "Emotional Reaction::Suicide";        //42
 FLAGSTRINGS[i++] = "Emotional Reaction::Relief";         //27
 FLAGSTRINGS[i++] = "Other::Pregnant";                    //20
 FLAGSTRINGS[i++] = "Breakup Factors::Someone told";      //15
 FLAGSTRINGS[i++] = "Other::Cutting";                     //10
 FLAGSTRINGS[i++] = "Breakup Factors::Seeing other people";//9
 FLAGSTRINGS[i++] = "Other::Abortion";                     //4
 
 */
