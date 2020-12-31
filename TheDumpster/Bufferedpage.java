/*

  This is free to use without restrictions of any kind. No warranty implied aka use at your own risk.
  Author : Max Stocker
  Note : This header can certainly be removed I just want to make clear that this is my orginial work and not taken from elsewhere
*/

import java.io.IOException;

/** The Bufferedpage class provides buffered read and write access to a page of data. Basically reading and writing of all
  primitives are supported and there are special methods for reading and writing blocks (byte[]) of data at a time. */
public final class Bufferedpage{

private boolean needsFlush;
public byte[] buff;
private int pos;

/** Creates a new empty size buffered page. */
public Bufferedpage(){
  buff = new byte[0];
  needsFlush = false;
  pos = 0;
}

/** Creates a buffered page of the given size. */
public Bufferedpage(int initialsize){
  buff = new byte[initialsize];
  for(int i=0;i<buff.length;i++){
    buff[i] = 0x00;
  }
  needsFlush = false;
  pos = 0;
}

/** Sets the buffer content to be toLoad. */
public void loadBuffer(byte[] toLoad){
  buff = toLoad;
  needsFlush = false;
  pos = 0;
}

/** Returns the contents of the buffer as a byte array. This resets the needsFlush flag.*/
public byte[] getBufferContents(){
  needsFlush = false;
  return buff;
}

/** Returns true if this buffer needs to be flushed. This will return true if any write operations
    were called on the buffer contents.*/
public boolean bufferNeedsFlush(){
  return needsFlush;
}

/** Seeks to the position in the buffer. */
public void seek(int position){
  pos = position;
  if(pos<0){
    pos = 0;
  }
}

/** Returns the current position in the buffer. */
public int getPosition(){
  return pos;
}

/** Returns the size of the current buffer. */
public int getSize(){
  return buff.length;
}

/** Returns an int read from the current position. */
public int readInt()throws IOException{
  int ch1 = readByte();
  int ch2 = readByte();
  int ch3 = readByte();
  int ch4 = readByte();
  return ((ch1 << 24) & 0xFF000000) + ((ch2 << 16) & 0x00FF0000) + ((ch3 << 8) & 0x0000FF00) + ((ch4 << 0) & 0x000000FF);
}

/** Returns a byte read from the current position. */
public byte readByte()throws IOException{
  if(pos>=buff.length){
    throw new IOException("Buffer Overflow Exception");
  }
  byte tr = buff[pos];
  pos++;
  return tr;
}

/** Returns a long read from the current position. */
public long readLong()throws IOException{
  return ((long)(readInt()) << 32) + (readInt() & 0xFFFFFFFFL);
}

/** Returns a float read from the current position. */
public float readFloat()throws IOException{
  return Float.intBitsToFloat(readInt());
}

/** Returns a double read from the current position. */
public double readDouble()throws IOException{
  return Double.longBitsToDouble(readLong());
}

/** Returns a short read from the current position. */
public short readShort()throws IOException{
  byte ch1 = readByte();
  byte ch2 = readByte();
  return (short)(((ch1 << 8 )& 0x0000FF00) + ((ch2 << 0)& 0x000000FF));
}

/** Returns a boolean read from the current position. */
public boolean readBoolean()throws IOException{
  return (readByte()==0x01);
}

/** Writes the byte b starting at the current position. */
public void writeByte(byte b)throws IOException{
  write(b);
}

/** Writes the short s starting at the current position. */
public void writeShort(short s)throws IOException{
  write((byte)((s >>> 8) & 0xFF));
  write((byte)((s >>> 0) & 0xFF));
}

/** Writes the int v starting at the current position. */
public void writeInt(int v)throws IOException{
  write((byte)((v >>> 24) & 0xFF));
  write((byte)((v >>> 16) & 0xFF));
  write((byte)((v >>>  8) & 0xFF));
  write((byte)((v >>>  0) & 0xFF));
}

/** Writes the long v starting at the current position. */
public void writeLong(long v)throws IOException{
  write((byte)((v >>> 56) & 0xFF));
  write((byte)((v >>> 48) & 0xFF));
  write((byte)((v >>> 40) & 0xFF));
  write((byte)((v >>> 32) & 0xFF));
  write((byte)((v >>> 24) & 0xFF));
  write((byte)((v >>> 16) & 0xFF));
  write((byte)((v >>>  8) & 0xFF));
  write((byte)((v >>>  0) & 0xFF));
}

/** Writes the float v starting at the current position. */
public void writeFloat(float v)throws IOException{
  writeInt(Float.floatToIntBits(v));
}

/** Writes the double v starting at the current position. */
public void writeDouble(double v)throws IOException{
  writeLong(Double.doubleToLongBits(v));
}

/** Writes the boolean b starting at the current position. */
public void writeBoolean(boolean b)throws IOException{
  if(b){
    writeByte((byte)0x01);
  }else{
    writeByte((byte)0x00);
  }
}

/** Reads an array of bytes from the buffer. This method is more efficent than reading individual
    bytes because it uses System.arraycopy instead of reading byte by byte.
*/
public byte[] readBytes(int size)throws IOException{
  if((buff.length-pos)<size){
    throw new IOException("Buffer Overflow Exception");
  }
  byte[] temp = new byte[size];
  System.arraycopy(buff,pos,temp,0,size);
  return temp;
}

/** Writes an array of bytes to the buffer starting at the current position. */
public void writeBytes(byte[] b)throws IOException{
  if((buff.length-pos)<b.length){
    throw new IOException("Buffer Overflow Exception");
  }
  System.arraycopy(b,0,buff,pos,b.length);
  needsFlush = true;
}

private void write(byte b)throws IOException{
  if(pos>=buff.length){
    throw new IOException("Buffer Overflow Exception");
  }
  buff[pos] = b;
  pos++;
  needsFlush = true;
}

}
