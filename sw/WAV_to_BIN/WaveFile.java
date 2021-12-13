import java.io.*;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.util.Arrays;

public class WaveFile {

    private byte[] header;
    private byte[] data;
    private int sampleRate;
    private short numChannels;
    private short bitsPerSample;

    public static void main(String[] args) throws IOException {

        File in = new File("src/ghu_unedited.wav");
        File out = new File("src/out.bin");

        WaveFile w = WaveFile.from(in);

        System.out.println("Sample Rate: " + w.getSampleRate());
        System.out.println("Bits Per Sample: " + w.getBitsPerSample());
        System.out.println("Elements: " + w.shortLength());

        FileWriter wr = new FileWriter(out);

        for (int i = 0; i < w.byteLength(); i++) {
            wr.write(w.getByte(i));
        }

        wr.close();

    }

    public static WaveFile from(File f) throws IOException {

        FileInputStream fileInputStream = new FileInputStream(f);

        WaveFile waveFile = new WaveFile();

        waveFile.header = fileInputStream.readNBytes(44);

        int dataSize = ByteBuffer.wrap(waveFile.header, 40, 4).order(ByteOrder.LITTLE_ENDIAN).getInt();

        waveFile.data = fileInputStream.readNBytes(dataSize);
        waveFile.sampleRate = ByteBuffer.wrap(waveFile.header, 24, 4).order(ByteOrder.LITTLE_ENDIAN).getInt();
        waveFile.numChannels = ByteBuffer.wrap(waveFile.header, 22, 2).order(ByteOrder.LITTLE_ENDIAN).getShort();
        waveFile.bitsPerSample = ByteBuffer.wrap(waveFile.header, 34, 2).order(ByteOrder.LITTLE_ENDIAN).getShort();

        fileInputStream.close();

        return waveFile;

    }

    public int getBitsPerSample() {
        return bitsPerSample;
    }

    public int getNumChannels() {
        return numChannels;
    }

    public int getSampleRate() {
        return sampleRate;
    }

    public int byteLength() {
        return data.length;
    }

    public int shortLength() {
        return data.length / 2;
    }

    public byte getByte(int i) {
        return data[i];
    }

    public short getShort(int i) {
        short s = 0;
        s |= data[2 * i];
        s |= data[2 * i + 1] << 8;
        return s;
    }

}
