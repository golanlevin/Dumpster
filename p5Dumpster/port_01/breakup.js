class Breakup {

    //=============================================================
    constructor (id) {

        this.ID = id; // 0...20000
        this.age = 0;
        this.sex = 0;
        this.date = 0;
        this.heartRadius = HEART_AVG_RAD;

        this.languageData = [];
        this.languageTags = [];
        this.bitValues = []; // was int[32];

        this.bIdValid = false;
        this.b_normalizeByStdvs = false;
        this.distanceFromCurrBupByLanguage = 0.0;
        this.langMetric = 0;
        this.VALID = true;

        this.nBitsSet = 0;
        this.summaryLen = 0; 
        this.kamalTags = 0; 

        this.fault = 0;
        this.instigator = 0;
        this.accessTags = 0;

        if ((id >= 0) && (id < N_BREAKUP_DATABASE_RECORDS)) {
          this.bIdValid = true;
        }

        for (var i=0; i<N_BREAKUP_LANGUAGE_DESCRIPTORS; i++) {
            this.languageData[i] = 0.0;
        }

        for (var i=0; i<N_BREAKUP_LANGUAGE_BITFLAGS; i++) {
            this.languageTags[i] = 0;
        }
    
        for (var i=0; i<32; i++) {
            this.bitValues[i] = 1<<i;
        }
    }
  

    //=============================================================
    compareTo (BR, method) {
  
      var out = 0;
      switch (method) {
      default:
        case BUP_COMPARE_AGE:
          if (BR.age < age) {
            out = -1;
          } else if (BR.age == age) {
            out = 0;
          } else {
            out = 1;
          }
          break;
  
        case BUP_COMPARE_SEX:
          if (BR.sex < sex) {
            out = -1;
          } else if (BR.sex == sex) {
            out = 0;
          } else {
            out = 1;
          }
          break;
  
        case BUP_COMPARE_INSTIG:
          if (BR.instigator < instigator) {
            out = -1;
          } else if (BR.instigator == instigator) {
            out = 0;
          } else {
            out = 1;
          }
          break; 
    
        case BUP_COMPARE_LANG:
          if (BR.langMetric < langMetric) {
            out = 1;
          } else if (BR.langMetric == langMetric) {
            out = 0;
          } else {
            out = -1;
          }
          break;
      }
  
      return out;
    }
  
    
    //=============================================================
    setAccessTags ( good,  gen,  flt,  instig, themes) {
      this.VALID 	      = (good > 0) ? true : false;
      this.sex 		      = gen;
      this.fault 	      = flt;
      this.instigator 	= instig;
      this.accessTags 	= themes;
    }

  
    //=============================================================
    setKamalFlags (a, d, kt) {
      this.age 	        = a;
      this.date 	      = d;
      this.kamalTags    = kt;
    }
  

    //=============================================================
    setLanguageTags (dat) {
      for (var i=0; i<N_BREAKUP_LANGUAGE_BITFLAGS; i++) {
        this.languageTags[i] = dat[i];
      }
    }
  

    //=============================================================
    setLanguageData (dat) {
      for (var i=0; i<N_BREAKUP_LANGUAGE_DESCRIPTORS; i++) {
        this.languageData[i] = dat[i];
      }
  
      if (this.b_normalizeByStdvs) {
        for (var i=0; i<N_BREAKUP_LANGUAGE_DESCRIPTORS; i++) {
          this.languageData[i] -= LANG_MEANS[i];
          this.languageData[i] /= LANG_STDVS[i];
        }
      }
    }
  
    //=============================================================
    setSummaryLength( slen) {
      this.summaryLen = slen;
  
      var fuk = languageData[2];
      var cap = languageData[3];
      this.langMetric = slen/255.0 + fuk + cap;
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
    computeNBitsSet() {
      var n = 0;
  
      if (this.age > 0) 			n++;
      if (this.sex > 0) 			n++;
      if (this.fault > 0) 		    n++;
      if (this.instigator > 0)	    n++;
  
      for (var b=0; b<32; b++) {
        if ((this.kamalTags  & this.bitValues[b]) > 0) n++;
        if ((this.accessTags & this.bitValues[b]) > 0) n++;
        for (var j=0; j<N_BREAKUP_LANGUAGE_BITFLAGS; j++) {
          if ((this.languageTags[j] & this.bitValues[b]) > 0) n++;
        }
      }
  
      this.nBitsSet = n;
      return this.nBitsSet;
    }
  
  
    //=============================================================
    computeHeartRadius() {
      // given the nBitsSet, which ranges from 0..16 with average 3.97, 
      // given the summaryLen, which ranges from 0(3)..255 with average 171,
      // determine the radius of my heart.
      
      var NBITSPOW  = (float)( Math.log(0.5) / Math.log(3.97/16.0) );
      var NLENPOW   = (float)( Math.log(0.5) / Math.log(171.0/255.0) );
  
      var maxBitsSetf = 12; //CLAMPING: actually, 16 empirical
      var nBitsFrac = Math.min(1.0, this.nBitsSet/maxBitsSetf); 
      nBitsFrac = (Math.pow(nBitsFrac, NBITSPOW)); 
  
      var maxSummaryLen = 230; //CLAMPING: actually 255 empirical
      var nLenFrac = Math.min(1.0, this.summaryLen/maxSummaryLen);
      nLenFrac = (Math.pow(nLenFrac, NLENPOW)); 
  
      // now both nBitsFrac and nLenFrac vary between 0..1, 
      // and have collection averages centered on 0.5.
      // create a weighted mixture of the two properties. 
      var radiusFrac = (0.25*nBitsFrac) + (0.75*nLenFrac);
      radiusFrac  = Math.pow(radiusFrac, 2.75); 
      this.heartRadius =  HEART_MIN_RAD + radiusFrac*(HEART_MAX_RAD - HEART_MIN_RAD);
    }
  
  
    //=============================================================
    // This should be replaced by T-SNE distance. ///GL
    computeLanguageDistance (otherLanguageData) {
      var dval;
      var dist = 0.0;
  
      for (var i=0; i<N_BREAKUP_LANGUAGE_DESCRIPTORS; i++) {
        dval = (languageData[i] - otherLanguageData[i]);
        dist += dval*dval;
      }
      dist = Math.sqrt(dist);
      this.distanceFromCurrBupByLanguage = dist;
      return dist;
    }
  

    //=============================================================
    computeLanguageTagNCommonalities (otherTags) {
      const langTagRelativeValues = [ 0.80, 1.00, 0.50, 0.40 ];
  
      var nScaledCommonProperties = 0;
      for (var i=0; i<N_BREAKUP_LANGUAGE_BITFLAGS; i++) {
        var commonProperties = (this.languageTags[i] & otherTags[i]); 
  
        for (var b=0; b<32; b++) {
          if ((commonProperties & this.bitValues[b]) > 0) {
            nScaledCommonProperties += langTagRelativeValues[i];
          }
        }
      }
      return nScaledCommonProperties;
    }
  

    //=============================================================
    computeKamalTagCommonalities (otherKTags) {
      var nCommonProperties = 0;
      var commonProperties = (this.kamalTags & otherKTags); 
      for (var b=0; b<32; b++) {
        if ((commonProperties & this.bitValues[b]) > 0) {
          nCommonProperties ++;
        }
      }
      return nCommonProperties;
    }
  

    //=============================================================
    computeAccessTagCommonalities (otherSex, otherFault, otherInstigator, otherAccessTags) {
      var nCommonProperties = 0;
      nCommonProperties += (this.sex & otherSex);
      nCommonProperties += (this.fault & otherFault);
      nCommonProperties += (this.instigator & otherInstigator); 
  
      var commonProperties = (this.accessTags & otherAccessTags); 
      for (var b=0; b<10; b++) {
        if ((commonProperties & this.bitValues[b]) > 0) {
          nCommonProperties ++;
        }
      }
      return nCommonProperties;
    }
  

    //=============================================================
    computeAgeDifference (otherAge) {
      var out = 0;
      if ((age != 0) && (otherAge != 0)) {
        out = Math.abs (age - otherAge);
      } 
      else {
        out = DUMPSTER_INVALID;
      }
      return out;
    }

}	
  
  
  