class BreakupManager {

  Breakup bups[];

  int 	currentlySelectedBreakupId;
  float distancesByLang[];
  float similaritiesByTag[];
  float similaritiesByKamal[];
  float similaritiesByAccess[];
  float distancesByAge[];
  float distancesByLen[];

  float SIMILARITIES[]; // language-based similarities
  int   MALES[];

  float meanLangDistance;
  float stdvLangDistance;


  boolean bDebugBM = true;
  float tempLangPacket[];
  int tempLangTagInts[];


  //=====================================================================================
  public BreakupManager () {

    bups = new Breakup[N_BREAKUP_DATABASE_RECORDS];
    for (int i=0; i<N_BREAKUP_DATABASE_RECORDS; i++) {
      bups[i] = new Breakup(i);
    }
    
    if (bDebugBM){
      println("Created " + N_BREAKUP_DATABASE_RECORDS + " new breakups"); 
    }

    currentlySelectedBreakupId = DUMPSTER_INVALID;
    meanLangDistance = 0;
    stdvLangDistance = 0;

    SIMILARITIES	 = new float[N_BREAKUP_DATABASE_RECORDS]; 
    distancesByLen	 = new float[N_BREAKUP_DATABASE_RECORDS];  
    distancesByLang   	 = new float[N_BREAKUP_DATABASE_RECORDS];
    distancesByAge	 = new float[N_BREAKUP_DATABASE_RECORDS]; 
    similaritiesByTag 	 = new float[N_BREAKUP_DATABASE_RECORDS];
    similaritiesByKamal  = new float[N_BREAKUP_DATABASE_RECORDS]; 
    similaritiesByAccess = new float[N_BREAKUP_DATABASE_RECORDS];  
    MALES		 = new int  [N_BREAKUP_DATABASE_RECORDS];  

    for (int i=0; i<N_BREAKUP_DATABASE_RECORDS; i++) {
      SIMILARITIES[i]		= 0.0f;
      MALES[i] = 0;

      distancesByLen[i]		= 0.0f; 
      distancesByAge[i] 	= 0.0f;
      distancesByLang[i]   = 0.0f;
      similaritiesByTag[i] = 0.0f;
      similaritiesByKamal[i] = 0.0f;
      similaritiesByAccess[i] = 0.0f;
    }

    tempLangPacket = new float[N_BREAKUP_LANGUAGE_DESCRIPTORS];
    tempLangTagInts = new int[N_BREAKUP_LANGUAGE_BITFLAGS];

    loadLanguageDataIntoBreakups();
    loadLanguageTagsIntoBreakups();
    loadKamalDataIntoBreakups();
    loadAccessThemesIntoBreakups();
    loadSummaryLengthsIntoBreakups();

    computeNBitsSet();
    computeBreakupHeartRadii();
  }

  /*
	Other due credits: I found the dumpster through Wealth Bondage.
   	 I see here that it's been in MetaFilter, Kottke, Logopolis, Brainwidth,
   	  hominid211, Jim Coudal, Rage on Omnipotent, Regine Debatty, cw wang, 
   	  Christiane Paul, information aesthetics, Seb Chan, Matthew Hurst, 
   	  David Balluff, love-dna, networked_performance, Crackunit, loreto martin,
   	   Joseph Cartman, newmediafix...
   	*/

  //=====================================================================================
  void computeBreakupHeartRadii() {
    for (int i=0; i<N_BREAKUP_DATABASE_RECORDS; i++) {
      bups[i].computeHeartRadius();
    }
  }


  //=====================================================================================
  void computeNBitsSet() {
    //int maxNSet = 0; 
    //int minNSet = 999999; 
    //float avgSet = 0;

    for (int i=0; i<N_BREAKUP_DATABASE_RECORDS; i++) {
      int nb = bups[i].computeNBitsSet();
      //if (nb > maxNSet){ maxNSet = nb; }
      //if (nb < minNSet){ minNSet = nb; } 
      //avgSet += nb;
    }

    // range is // 0...16, average = 3.97

    //System.out.println("set: " + minNSet + " " + maxNSet); 
    //avgSet /= (float)N_BREAKUP_DATABASE_RECORDS;
    //System.out.println("avgSet " + avgSet);
  }

  //=====================================================================================
  void loadSummaryLengthsIntoBreakups() {

    byte b[] = loadBytes("breakupSummaryLengths.dat"); 
    int nBytes = b.length;

    // average length is around 170 chars.

    for (int i=0; i<nBytes; i++) { 
      int byteVal = (int)(b[i] & 0xFF); //converts to 0 to 255 
      bups[i].setSummaryLength(byteVal);
    }
  }

  //=====================================================================================
  void loadLanguageTagsIntoBreakups() {
    String lines[] = loadStrings("languageTags.txt"); 
    int nLines = lines.length;

    if ((nLines > 0) && (nLines <= N_BREAKUP_DATABASE_RECORDS)) {
      for (int i=0; i<nLines; i++) {
        String strVals[] = split(lines[i], ' ');
        int nVals = strVals.length;
        // if (bDebugBM) System.out.println("loadLanguageTagsIntoBreakups: " + i + " has " + nVals);
        if (nVals == N_BREAKUP_LANGUAGE_BITFLAGS) {

          for (int f=0; f<N_BREAKUP_LANGUAGE_BITFLAGS; f++) {
            tempLangTagInts[f] = Integer.parseInt(strVals[f]);
          }
          bups[i].setLanguageTags (tempLangTagInts);
        }
      }
    }
  }


  //=====================================================================================
  void loadKamalDataIntoBreakups() {
    String lines[] = loadStrings("kamalFlags.txt"); 
    int nLines = lines.length;

    if ((nLines > 0) && (nLines <= N_BREAKUP_DATABASE_RECORDS)) {
      for (int i=0; i<nLines; i++) {
        String strVals[] = split(lines[i], '\t');
        int nVals = strVals.length;
        if (nVals == 3) {

          int age   = Integer.parseInt(strVals[0]);
          int date  = Integer.parseInt(strVals[1]);
          int flags = Integer.parseInt(strVals[2]);
          bups[i].setKamalFlags (age, date, flags);
        }
      }
    }
  }


  //=====================================================================================
  void loadAccessThemesIntoBreakups() {
    String lines[] = loadStrings("accessThemes.txt"); 
    int nLines = lines.length;

    if ((nLines > 0) && (nLines <= N_BREAKUP_DATABASE_RECORDS)) {
      for (int i=0; i<nLines; i++) {

        String strVals[] = split(lines[i], '\t');
        int nVals = strVals.length;
        if (nVals == 5) {

          int good_data   = Integer.parseInt(strVals[0]);
          int gender 	  = Integer.parseInt(strVals[1]); 
          int fault 	  = Integer.parseInt(strVals[2]);
          int instig	  = Integer.parseInt(strVals[3]); 
          int themes	  = Integer.parseInt(strVals[4]);  

          bups[i].setAccessTags (good_data, gender, fault, instig, themes);
          MALES[i] = (gender == 2) ? MALE_BLUE_AMOUNT:0;
        }
      }
    }
  }



  //=====================================================================================
  void loadLanguageDataIntoBreakups() {

    String lines[] = loadStrings("languageData.txt");
    int nLines = lines.length;
    if (bDebugBM) println ("loadLanguageDataIntoBreakups: reading " + nLines );  
    
    if ((nLines > 0) && (nLines <= N_BREAKUP_DATABASE_RECORDS)) {
      if (bDebugBM) System.out.println("languageData has " + nLines); 
      float div = 1.0f/(float)(1<<15);

      for (int i=0; i<nLines; i++) {
        String strVals[] = splitTokens (lines[i], "\t");
        int nVals = strVals.length;
        if (nVals == N_BREAKUP_LANGUAGE_DESCRIPTORS) {

          for (int j=0; j<N_BREAKUP_LANGUAGE_DESCRIPTORS; j++) {
            int   valji = Integer.parseInt(strVals[j]);
            float valjf = (float)valji * div;
            tempLangPacket[j] = valjf;
          }
          bups[i].setLanguageData(tempLangPacket);
        } 
        else {
          if (bDebugBM) System.out.println("Problem loading languageData line " + i);
        }
      }
    } 
    else {
      if (bDebugBM) System.out.println("Error loading languageData");
    }
  }



  //=====================================================================================
  void informOfNewlySelectedBreakup (int bupId) {
    if ((bupId > 0) && (bupId <= N_BREAKUP_DATABASE_RECORDS)) {
      currentlySelectedBreakupId = bupId;
    } 
    else {
      currentlySelectedBreakupId = DUMPSTER_INVALID;
    }
    computeSimilarityOfAllBupsToCurrBup();
  }





  //=====================================================================================
  void computeSimilarityOfAllBupsToCurrBup () {
    long startTime = System.currentTimeMillis();

    //---------------------------------------------
    // compute distances to current Breakup
    float distL;
    float distT;
    float distK;
    float distA;

    float maxDistL = 0;
    float maxDistT = 0;
    float maxDistK = 0;
    float maxDistA = 0;

    if (currentlySelectedBreakupId != DUMPSTER_INVALID) {
      float currBupLangData[] = bups[currentlySelectedBreakupId].languageData;
      int   currBupLangTags[] = bups[currentlySelectedBreakupId].languageTags;
      int 	currKamalTags		= bups[currentlySelectedBreakupId].kamalTags;
      int 	currAge				= bups[currentlySelectedBreakupId].age;
      int 	currSex				= bups[currentlySelectedBreakupId].sex;
      int 	currFault			= bups[currentlySelectedBreakupId].fault;
      int 	currInstg			= bups[currentlySelectedBreakupId].instigator;
      int 	currAccessTags		= bups[currentlySelectedBreakupId].accessTags;  
      int 	currLen				= bups[currentlySelectedBreakupId].summaryLen;

      for (int i=0; i<N_BREAKUP_DATABASE_RECORDS; i++) {

        // compute euclidean distance of float-based language metrics. LARGER is WORSE.
        distancesByLang[i]   = distL = bups[i].computeLanguageDistance (currBupLangData);

        // compute number of overlapping (scaled) language categories. LARGER is BETTER.
        similaritiesByTag[i] = distT = bups[i].computeLanguageTagNCommonalities (currBupLangTags);

        // compute number of overlapping (scaled) kamal categories. LARGER is BETTER.
        similaritiesByKamal[i] = distK = bups[i].computeKamalTagCommonalities (currKamalTags);

        // compute # of similarities using access-annotated themes. 
        similaritiesByAccess[i] = distA = bups[i].computeAccessTagCommonalities (currSex, currFault, currInstg, currAccessTags);

        // compute absolute difference in age
        distancesByAge[i] = bups[i].computeAgeDifference (currAge);

        distancesByLen[i] = (Math.abs(currLen - bups[i].summaryLen))/255.0f;


        if (distL > maxDistL) { 
          maxDistL = distL;
        }
        if (distT > maxDistT) { 
          maxDistT = distT;
        }
        if (distK > maxDistK) { 
          maxDistK = distK;
        }
        if (distA > maxDistA) { 
          maxDistA = distA;
        }
      }
    }


    //=======================================================
    // normalize float lang distances using maxDistL.
    // meanwhile, compute mean and standard deviation.
    // standard dev is used to compute %iles for contrast enhancement.
    final float nBupsf = (float)N_BREAKUP_DATABASE_RECORDS;
    meanLangDistance = 0;
    stdvLangDistance = 0;
    if (maxDistL > 0.0f) {
      float normalizeL = (1.0f/maxDistL);
      for (int i=0; i<N_BREAKUP_DATABASE_RECORDS; i++) {
        meanLangDistance += (distancesByLang[i] *= normalizeL);
      }  
      meanLangDistance /= nBupsf;

      //---------------------------------------------
      for (int i=0; i<N_BREAKUP_DATABASE_RECORDS; i++) {
        float dm = distancesByLang[i] - meanLangDistance;
        stdvLangDistance += dm*dm;
      }  
      stdvLangDistance = (float)Math.sqrt((1.0f/(nBupsf-1.0f)) * stdvLangDistance);
    }
    //---------------------------------------------
    // normalize lang tag similarities using maxDistT
    if (maxDistT > 0.0) {
      final float normalizeT = (1.0f/maxDistT);
      for (int i=0; i<N_BREAKUP_DATABASE_RECORDS; i++) {
        similaritiesByTag[i] *= normalizeT;
      }
    }
    //---------------------------------------------
    // normalize kamal tag similarities using maxDistK
    if (maxDistK > 0.0) {
      final float normalizeK = (1.0f/maxDistK);
      for (int i=0; i<N_BREAKUP_DATABASE_RECORDS; i++) {
        similaritiesByKamal[i] *= normalizeK;
      }
    }
    //---------------------------------------------
    // normalize access tag similarities using maxDistK
    if (maxDistA > 0.0) {
      final float normalizeA = (1.0f/maxDistA);
      for (int i=0; i<N_BREAKUP_DATABASE_RECORDS; i++) {
        similaritiesByAccess[i] *= normalizeA;
      }
    }


    //---------------------------------------------
    // CONTRAST ENHANCEMENT OF LANG DISTANCES
    // All distancesByLang[i] are in the range 0..1.
    // clamp data outside 2 standard deviations, and re-stretch range
    boolean bEnhanceContrast = true;
    if (bEnhanceContrast) {
      if (stdvLangDistance > 0) {

        float loVal = Math.min(1, Math.max(0, meanLangDistance - (2.25f * stdvLangDistance)));
        float hiVal = Math.max(0, Math.min(1, meanLangDistance + (2.00f * stdvLangDistance)));
        float range = hiVal - loVal;
        for (int i=0; i<N_BREAKUP_DATABASE_RECORDS; i++) {
          float val = distancesByLang[i];
          if (val <= loVal) {
            distancesByLang[i] = 0;
          } 
          else if (val >= hiVal) {
            distancesByLang[i] = 1;
          } 
          else {
            distancesByLang[i] = (val - loVal)/range;
          }
        }
      }
    }

    //---------------------------------------------
    // COMPUTE WEIGHTED SIMILARITIES

    float maxSimilarity = 0.0f; 

    for (int i=0; i<N_BREAKUP_DATABASE_RECORDS; i++) {

      float theSimilarity = 0.0f;
      if (bups[i].VALID) {

        float lenDist  = (1.0f - distancesByLen[i]); 
        float langDist = (1.0f - distancesByLang[i]);
        float tagSimil = similaritiesByTag[i];
        float kamSimil = similaritiesByKamal[i];
        float accSimil = similaritiesByAccess[i]; 

        boolean bTagSimil = (tagSimil > 0);
        boolean bkamSimil = (kamSimil > 0);



        float ageDist = 0.0f;
        if (distancesByAge[i] != DUMPSTER_INVALID) {
          ageDist = 1.0f - (Math.min(5.0f, distancesByAge[i])/5.0f);
        }


        if (bTagSimil && !bkamSimil) {
          theSimilarity = (0.05f*lenDist) + (0.10f*ageDist) + (0.20f*langDist) + (0.30f*tagSimil) +                    (0.40f*accSimil);
        } 
        else if (!bTagSimil && bkamSimil) {
          theSimilarity = (0.05f*lenDist) + (0.10f*ageDist) + (0.20f*langDist) +                    (0.40f*kamSimil) + (0.40f*accSimil);
        } 
        else if (bTagSimil && bkamSimil) {
          theSimilarity = (0.05f*lenDist) + (0.10f*ageDist) + (0.20f*langDist) + (0.30f*tagSimil) + (0.40f*kamSimil) + (0.40f*accSimil);
        } 
        else {
          theSimilarity = (0.05f*lenDist) + (0.10f*ageDist) + (0.20f*langDist) +                                       (0.40f*accSimil);
        }


        if (theSimilarity > maxSimilarity) {
          maxSimilarity = theSimilarity;
        }
      }


      SIMILARITIES[i] = theSimilarity;
    }


    if (maxSimilarity < 1.0) {
      maxSimilarity = (float) Math.pow(maxSimilarity, 0.95f);
    }


    // try normalizing to 0...1
    if (maxSimilarity > 0.0f) {
      for (int i=0; i<N_BREAKUP_DATABASE_RECORDS; i++) {
        SIMILARITIES[i] /= maxSimilarity;
      }
    }


    //---------------------------------------------
    //long now = System.currentTimeMillis();
    //long calculationTime = now - startTime;
    //System.out.println("computeLanguageDistance took " + calculationTime);
  }
}

