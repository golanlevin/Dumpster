import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.net.URL;
import java.text.DecimalFormat;
import java.text.NumberFormat;

public class SadnessFetcher implements Runnable {

  private final URL base;
  private final ParagraphBalloon balloon;
  private final int id;

  public SadnessFetcher(URL base, int id, ParagraphBalloon balloon)
  {
    this.base = base;
    this.id = id;
    this.balloon = balloon;
    
    // should run be called?
  }

  private final NumberFormat F = new DecimalFormat("00000");

  public void run()
  {

    if (KIOSK_MODE) { // must be true for the current application 
      String idString = F.format(id);
      String path = idString.charAt(0) + "/" + idString.charAt(1) + "/" + idString.charAt(2) + "/" + idString + ".txt";
      path = "text/" + path;
      String lines[] = loadStrings(path); 
      int nLines = lines.length;
      if (nLines > 1) {
        String verbiage = lines[1];
        boolean bOnlyLoading = false;
        balloon.setStringAndComputeLayout(verbiage, id, bOnlyLoading);
      }
    } 
  }

  private String getString (InputStream in) throws IOException{
    
    StringBuffer contents = new StringBuffer();
    Reader reader = new BufferedReader(new InputStreamReader(in));
    int n;
    char[] buf = new char[1024];
    try
    {
      while ( (n = reader.read (buf)) != -1)
        contents.append(buf, 0, n);
    }
    finally
    {
      reader.close();
    }
    return contents.toString();
  }
}

