import java.applet.*; 
import java.awt.*; 
import java.awt.image.*; 
import java.awt.event.*; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 

public class PixelIndexer {


  short PixelIndexToBupIndex[];
  int BupIndexToPixelIndex[];
  int nPixels;
  boolean bComputedLUT;


  BreakupManager BM;
  Vector V;

  public PixelIndexer (BreakupManager bm) {

    nPixels = PIXELVIEW_W * PIXELVIEW_H;
    PixelIndexToBupIndex = new short[nPixels];
    for (int i=0; i<nPixels; i++) {
      PixelIndexToBupIndex[i] = 0;
    }

    BupIndexToPixelIndex = new int[N_BREAKUP_DATABASE_RECORDS];
    for (int i=0; i<N_BREAKUP_DATABASE_RECORDS; i++) {
      BupIndexToPixelIndex[i] = DUMPSTER_INVALID;
    }


    BM = bm;
    V = new Vector(N_BREAKUP_DATABASE_RECORDS);
    for (int i=0; i<N_BREAKUP_DATABASE_RECORDS; i++) {
      V.addElement(BM.bups[i]);
    }

    sort1_EntireSetByAge();
    sort2_AgeByLanguage();
    sort3_RowsOf50BySex();
    sort4_ByInstigator();
     
    for (int i=0; i<nPixels; i++) {
      Breakup ithSortedByAgeBreakup = ((Breakup)V.elementAt(i));
      int bupId = ithSortedByAgeBreakup.ID;

      PixelIndexToBupIndex[i] = (short) bupId;
      BupIndexToPixelIndex[bupId] = i;
    }



    bComputedLUT = true;
  }


  //==================================================================
  void sort1_EntireSetByAge() {
    quickSort(V, BUP_COMPARE_AGE);
  }

  //==================================================================
  void sort2_AgeByLanguage() {

    Breakup bup0 = ((Breakup)V.elementAt(0));
    int age0 = bup0.age;
    int age1;

    int ageIndexLo = 0;
    int ageIndexHi = 0;
    int nm1 = N_BREAKUP_DATABASE_RECORDS_20K-1;

    
    for (int i=1; i<N_BREAKUP_DATABASE_RECORDS_20K; i++) {
      Breakup bupi = ((Breakup)V.elementAt(i));
      age1 = bupi.age;
      
      //println(i + " " + bupi.age + " " + bupi.sex); 

      if ((age1 < age0)||(i==nm1)) {
        ageIndexHi = i-1;
        if (ageIndexHi > ageIndexLo) {
          // System.out.println(age0 + ": " + ageIndexLo + " " + ageIndexHi);
          quickSort(V, ageIndexLo, ageIndexHi, BUP_COMPARE_LANG);
        }
        ageIndexLo = ageIndexHi;
      }
      age0 = age1;
    }
  }

  //==================================================================
  void sort3_RowsOf50BySex() {
    for (int y=0; y<PIXELVIEW_H; y++) {
      int indexLo = y*PIXELVIEW_W;
      int indexHi = (y+1)*PIXELVIEW_W - 1;
      quickSort(V, indexLo, indexHi, BUP_COMPARE_SEX);
    }
  }
  //==================================================================
  void sort4_ByInstigator() {
    for (int y=0; y<PIXELVIEW_H; y++) {
      int rowIndexLo = y*PIXELVIEW_W;
      int rowIndexHi = (y+1)*PIXELVIEW_W - 1;
      // rows of 50 are already sorted by Male, Female, N/A.

      for (int sex = 0; sex <=2; sex++) {
        int sexLoIndex = DUMPSTER_INVALID;
        int sexHiIndex = DUMPSTER_INVALID;

        for (int i=rowIndexLo; i<rowIndexHi; i++) {
          Breakup bup = ((Breakup)V.elementAt(i));
          if (bup.sex == sex) {
            if (sexLoIndex == DUMPSTER_INVALID) {
              sexLoIndex = i;
            }
            sexHiIndex = i;
          }
        }
        if ((sexLoIndex != DUMPSTER_INVALID) && 
          (sexHiIndex != DUMPSTER_INVALID)) {
          quickSort(V, sexLoIndex, sexHiIndex, BUP_COMPARE_INSTIG);
        }
      }
    }
  }


  /////////////////////////////////////////////////////////////////////////////////////////////////

  /*
if (i%100 == 0){
   	int age = ((Breakup)V.elementAt(i)).age;
   	System.out.println(i + " " + age);
   }
   */



  /////////////////////////////////////////////////////////////////////////////////////////////////

  // Sort the entire vector, if it is not empty
  public void quickSort(Vector elements, int method) {
    if (! elements.isEmpty()) {
      this.quickSort(elements, 0, elements.size()-1, method);
    }
  }



  private void quickSort (Vector elements, int lowIndex, int highIndex, int method) {
    int lowToHighIndex;
    int highToLowIndex;
    int pivotIndex;

    int NELTS =  elements.size()-1;

    Breakup pivotValue;  // values are Strings in this demo, change to suit your application
    Breakup lowToHighValue;
    Breakup highToLowValue;
    Breakup parking;

    int newLowIndex;
    int newHighIndex;
    int compareResult;

    lowToHighIndex = lowIndex;
    highToLowIndex = highIndex;
    pivotIndex = (lowToHighIndex + highToLowIndex) / 2;
    pivotValue = (Breakup)elements.elementAt(pivotIndex);

    /** Split the Vector in two parts.
     *
     *  The lower part will be lowIndex - newHighIndex,
     *  containing elements <= pivot Value
     *
     *  The higher part will be newLowIndex - highIndex,
     *  containting elements >= pivot Value
     */
    newLowIndex  = Math.max(0, Math.min(highIndex + 1, NELTS));
    newHighIndex = Math.min(NELTS, Math.max(0, lowIndex - 1));

    // loop until low meets high
    while ( (newHighIndex + 1) < newLowIndex) { // loop until partition complete
      // loop from low to high to find a candidate for swapping
      lowToHighValue = (Breakup)elements.elementAt(lowToHighIndex);
      while (	(lowToHighIndex < newLowIndex) && 
        (lowToHighIndex < NELTS) && 
        (lowToHighIndex > 0)	&& 
        lowToHighValue.compareTo (pivotValue, method) <0 ) {
        newHighIndex = lowToHighIndex; // add element to lower part
        lowToHighIndex ++;

        lowToHighValue = (Breakup)elements.elementAt(lowToHighIndex);
      }

      // loop from high to low find other candidate for swapping
      highToLowValue = (Breakup)elements.elementAt(highToLowIndex);
      while (	(newHighIndex <= highToLowIndex) && 
        (highToLowIndex < NELTS) && 
        (highToLowIndex > 0)	&& 
        (highToLowValue.compareTo(pivotValue, method)>0)) {
        newLowIndex = highToLowIndex; // add element to higher part
        highToLowIndex --;
        highToLowValue = (Breakup)elements.elementAt(highToLowIndex);
      }

      // swap if needed
      if (lowToHighIndex == highToLowIndex) {  		// one last element, may go in either part
        newHighIndex = lowToHighIndex; 				// move element arbitrary to lower part
      }
      else if (lowToHighIndex < highToLowIndex) {  	// not last element yet
        compareResult = lowToHighValue.compareTo(highToLowValue, method);
        if (compareResult >= 0) { 						// low >= high, swap, even if equal
          parking = lowToHighValue;
          elements.setElementAt(highToLowValue, lowToHighIndex);
          elements.setElementAt(parking, highToLowIndex);

          newLowIndex = highToLowIndex;
          newHighIndex = lowToHighIndex;

          lowToHighIndex ++;
          highToLowIndex --;
        }
      }
    }

    // Continue recursion for parts that have more than one element
    if (lowIndex < newHighIndex) {
      //System.out.println("QS: " + lowIndex + " " + newHighIndex); 
      this.quickSort(elements, lowIndex, newHighIndex, method); // sort lower subpart
    }
    if (newLowIndex < highIndex) {
      //System.out.println("QS: " + newLowIndex + " " + highIndex); 
      this.quickSort(elements, newLowIndex, highIndex, method); // sort higher subpart
    }
  }
}

