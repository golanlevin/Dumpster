
/**
 * This class converts long values to ASCII and vice versa
 */
class AsciiConverter
{
  static final String CHARS = "0123456789.abcdefghijklmnopqrstuvwxyz_ABCDEFGHIJKLMNOPQRSTUVWXYZ";

  // String8 to long conversion
  static long getAscii16(String s)
  {
    long val = 0;

    for (int i = s.length(); --i >= 0;)
    {
      val <<= 8;
      val |= ((long) s.charAt(i)) & 0xFF;
    }
    return val;
  }

  // long to String8 conversion
  static String toAscii16(long val)
  {
    StringBuffer s = new StringBuffer(16);
    for (int i = 0; i < 8; i++)
    {
      char c = (char) (val & 0xFF);
      if (c != '\0')
        s.append(c);
      val >>>= 8;
    }
    return s.toString();
  }

  // long to String11 conversion
  static String toAscii11(long val)
  {
    StringBuffer result = new StringBuffer(11);
    for (int i = 0; i < 10; i++)
    {
      result.append(CHARS.charAt((int) (val & 0x3F)));
      val >>>= 6;
    }
    result.append(CHARS.charAt((int) (val & 0xF)));
    return result.toString();
  }

  // String11 to long conversion
  static long getAscii11(String s)
  {
    long val = 0;
    for (int i = s.length(); --i >= 0;)
    {
      char c = s.charAt(i);
      int pos = CHARS.indexOf(c);
      val <<= 6;
      val |= pos;
    }
    return val;
  }
}

