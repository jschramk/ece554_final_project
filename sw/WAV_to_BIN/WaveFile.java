import java.io.*;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.util.Scanner;

public class WaveFile {

    private byte[] header;
    private byte[] data;
    private int sampleRate;
    private short numChannels;
    private short bitsPerSample;

    public static void main(String[] args) throws IOException {

        Scanner scanner = new Scanner(System.in);

        System.out.println("Choose a conversion:");
        System.out.println("1: .wav -> .bin");
        System.out.println("2: .bin -> .wav");
        System.out.println("3: Hex .txt -> .bin");
        System.out.println("4: .bin -> Binary .txt");
        System.out.print("> ");

        int option = -1;
        while (true) {
            String input = scanner.nextLine().trim();
            try {
                option = Integer.parseInt(input);
                if(option < 1 || option > 4) throw new Exception();
                break;
            } catch (Exception e) {
                System.out.print("Please enter a number from the list:\n> ");
            }
        }

        File in, out;
        while (true) {
            System.out.print("Enter the path of the input file:\n> ");
            String path = scanner.nextLine().trim();
            try {
                in = new File(path);
                if(!in.exists()) throw new Exception();
                break;
            } catch (Exception e) {
                System.out.println("Error: could not open that file.");
            }
        }

        while (true) {
            System.out.print("Enter the path of the output file:\n> ");
            String path = scanner.nextLine().trim();
            try {
                out = new File(path);


                if(out.exists()) {
                    System.out.print("Overwrite " + out.getName() + "? [y/n]\n> ");

                    boolean loop = true;
                    while (loop) {
                        String input = scanner.nextLine().trim().toLowerCase();
                        switch (input) {
                            case "y": {
                                loop = false;
                                break;
                            }
                            case "n": {
                                System.out.println("Operation canceled.");
                                return;
                            }
                            default: {
                                System.out.print("Please reply with y for yes or n for no:\n> ");
                                break;
                            }
                        }
                    }


                }

                break;
            } catch (Exception e) {
                System.out.println("Error: could not open that file.");
            }
        }

        switch (option) {
            case 1: {
                WAVtoBIN(in, out);
                break;
            }
            case 2: {
                BINtoWAV(in, out);
                break;
            }
            case 3: {
                HexTxtToBIN(in, out);
                break;
            }
            case 4: {
                BINtoBinaryTxt(in, out);
                break;
            }
        }

        System.out.println("Operation complete.");

    }

    public static void BINtoBinaryTxt(File in, File out) throws IOException {

        FileWriter fileWriter = new FileWriter(out);

        FileInputStream fileInputStream = new FileInputStream(in);

        while (true) {

            int read = fileInputStream.read();

            if (read == -1)
                break;

            String s = String.format(
                "%8s",
                Integer.toBinaryString(read)
            ).replace(' ', '0');

            fileWriter.write(s + "\n");

        }

        fileWriter.close();

        fileInputStream.close();

    }

    public static void WAVtoBIN(File in, File out) throws IOException {

        WaveFile w = fromWAV(in);

        FileWriter wr = new FileWriter(out);

        for (int i = 0; i < w.byteLength(); i++) {
            wr.write(w.getByte(i));
        }

        wr.close();

    }

    public static void BINtoWAV(File in, File out) throws IOException {

        FileInputStream fileInputStream = new FileInputStream(in);

        byte[] data = fileInputStream.readAllBytes();

        fileInputStream.close();

        writeWAV(out, data);

    }

    public static void HexTxtToBIN(File in, File out) throws IOException {

        Scanner s = new Scanner(in);

        FileOutputStream fileOutputStream = new FileOutputStream(out);

        while (s.hasNextLine()) {

            String line = s.nextLine().replaceAll("//.*", "").trim();

            try {

                byte b = Byte.parseByte(line, 16);

                fileOutputStream.write(b);

            } catch (Exception e) {
                // skip
            }

        }

        fileOutputStream.close();

    }

    public static WaveFile fromWAV(File f) throws IOException {

        FileInputStream fileInputStream = new FileInputStream(f);

        WaveFile waveFile = new WaveFile();

        waveFile.header = fileInputStream.readNBytes(44);

        int dataSize =
            ByteBuffer.wrap(waveFile.header, 40, 4).order(ByteOrder.LITTLE_ENDIAN).getInt();

        waveFile.data = fileInputStream.readNBytes(dataSize);
        waveFile.sampleRate =
            ByteBuffer.wrap(waveFile.header, 24, 4).order(ByteOrder.LITTLE_ENDIAN).getInt();
        waveFile.numChannels =
            ByteBuffer.wrap(waveFile.header, 22, 2).order(ByteOrder.LITTLE_ENDIAN).getShort();
        waveFile.bitsPerSample =
            ByteBuffer.wrap(waveFile.header, 34, 2).order(ByteOrder.LITTLE_ENDIAN).getShort();

        fileInputStream.close();

        return waveFile;

    }

    public static void writeWAV(File out, byte[] data) throws IOException {

        ByteBuffer b = ByteBuffer.allocate(44 + data.length).order(ByteOrder.LITTLE_ENDIAN);

        int sampleRate = 44100;
        int bitsPerSample = 16;
        int numChannels = 1;

        b.put("RIFF".getBytes());
        b.putInt(44 + data.length);
        b.put("WAVE".getBytes());
        b.put("fmt ".getBytes());
        b.putInt(16); // format length
        b.putShort((short) 1); // format type
        b.putShort((short) 1); // number of channels
        b.putInt(44100); // sample rate
        b.putInt(sampleRate * bitsPerSample * numChannels / 8);
        b.putShort((short) (bitsPerSample * numChannels / 8));
        b.putShort((short) bitsPerSample);
        b.put("data".getBytes());
        b.put(data);

        byte[] outBytes = b.array();

        FileOutputStream fileOutputStream = new FileOutputStream(out);

        fileOutputStream.write(outBytes);

        fileOutputStream.close();

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
