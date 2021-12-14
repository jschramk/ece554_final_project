import java.io.*;
import java.util.*;
import java.util.regex.Pattern;

public class Assembler {

    private static Pattern LABEL_PATTERN = Pattern.compile("\\.[a-zA-Z_][a-zA-Z_0-9]*");
    private static Pattern REGISTER_PATTERN = Pattern.compile("R[0-7]");
    private static Pattern HEX_PATTERN = Pattern.compile("0x[0-9a-fA-F]+");
    private static Pattern DEC_PATTERN = Pattern.compile("[0-9]+");

    public static void main(String[] args) throws IOException {

        Scanner userInputScanner = new Scanner(System.in);

        File in, out;
        while (true) {
            System.out.print("Enter the path of the input file:\n> ");
            String path = userInputScanner.nextLine().trim();
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
            String path = userInputScanner.nextLine().trim();
            try {
                out = new File(path);


                if(out.exists()) {
                    System.out.print("Overwrite " + out.getName() + "? [y/n]\n> ");

                    boolean loop = true;
                    while (loop) {
                        String input = userInputScanner.nextLine().trim().toLowerCase();
                        switch (input) {
                            case "y": {
                                loop = false;
                                break;
                            }
                            case "n": {
                                System.out.println("Operation canceled.");
                                userInputScanner.close();
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

        Scanner sc = new Scanner(in);

        Map<String, Integer> labels = new HashMap<>();
        List<String> instructions = new ArrayList<>();
        List<Short> codes = new ArrayList<>();

        int pc = 0;

        // gather labels and instructions without comments
        while (sc.hasNextLine()) {
            String line = sc.nextLine().trim().replaceAll("[ ]*//.*", "");
            if (isLabel(line)) {
                labels.put(line, pc);
            } else if (!line.isEmpty()) {
                instructions.add(line);
                pc += 2;
            }
        }

        // parse instructions to machine code
        for (int i = 0; i < instructions.size(); i++) {
            short code = parse(instructions.get(i), i * 2, labels);
            codes.add(code);
        }

        FileOutputStream fos = new FileOutputStream(out);

        for (Short s : codes) {

            String formatted = String.format("%16s", Integer.toBinaryString(s)).replace(' ', '0');
            //System.out.println(formatted);

            byte lower = (byte) (s & 0b11111111);
            byte upper = (byte) ((s & 0b11111111_00000000) >> 8);

            fos.write(new byte[] {lower, upper});

        }

        fos.close();

        System.out.println("Operation complete.");

    }

    private static boolean isHex(String s) {
        return HEX_PATTERN.matcher(s).matches();
    }

    private static boolean isDec(String s) {
        return DEC_PATTERN.matcher(s).matches();
    }

    private static boolean isLabel(String s) {
        return LABEL_PATTERN.matcher(s).matches();
    }

    private static boolean isRegister(String s) {
        return REGISTER_PATTERN.matcher(s).matches();
    }

    private static short parse(String line, int pc, Map<String, Integer> labels) {

        String[] args = line.split("[ ,]+");

        if (args.length < 1) {
            throw new IllegalArgumentException("Instruction is formatted incorrectly: " + line);
        }

        short code = 0;

        code |= getOpCode(args[0]) << 11;

        code |= parseByType(args, pc, labels);

        return code;

    }

    private static short parseSingleRegister(String[] args, int pc, Map<String, Integer> labels) {
        short code = 0;

        if (args.length != 2) {
            throw new IllegalArgumentException("Expected 1 argument: " + Arrays.toString(args));
        }

        if (!isRegister(args[1])) {
            throw new IllegalArgumentException("Expected register, got: " + args[1]);
        }

        code |= (Integer.parseInt(args[1].replaceAll("R", "")) & 0b111) << 8;

        return code;
    }

    private static short parseDoubleRegister(String[] args, int pc, Map<String, Integer> labels) {
        short code = 0;

        if (args.length != 3) {
            throw new IllegalArgumentException("Expected 2 arguments: " + Arrays.toString(args));
        }

        if (!isRegister(args[1])) {
            throw new IllegalArgumentException("Expected register, got: " + args[1]);
        }

        if (!isRegister(args[2])) {
            throw new IllegalArgumentException("Expected register, got: " + args[2]);
        }

        code |= (Integer.parseInt(args[1].replaceAll("R", "")) & 0b111) << 8;

        code |= (Integer.parseInt(args[2].replaceAll("R", "")) & 0b111) << 5;

        return code;
    }

    private static short parseRegisterImmediate(String[] args, int pc,
        Map<String, Integer> labels) {
        short code = 0;

        if (args.length != 3) {
            throw new IllegalArgumentException("Expected 2 arguments: " + Arrays.toString(args));
        }

        if (!isRegister(args[1])) {
            throw new IllegalArgumentException("Expected register, got: " + args[1]);
        }

        code |= (Integer.parseInt(args[1].replaceAll("R", "")) & 0b111) << 8;

        if (isHex(args[2])) {

            code |= Integer.parseInt(args[2].replaceAll("0x", ""), 16) & 0b11111111;

        } else if (isDec(args[2])) {

            code |= Integer.parseInt(args[2]) & 0b11111111;

        } else if (isLabel(args[2])) {

            int labelPc = labels.get(args[2]);

            int diff = labelPc - pc;

            code |= diff & 0b11111111;

        } else {
            throw new IllegalArgumentException("Expected immediate or label, got: " + args[2]);
        }

        return code;
    }

    private static short parseImmediate(String[] args, int pc, Map<String, Integer> labels) {
        short code = 0;

        if (args.length != 2) {
            throw new IllegalArgumentException("Expected 1 argument: " + Arrays.toString(args));
        }

        if (isHex(args[1])) {

            code |= Integer.parseInt(args[1].replaceAll("0x", ""), 16) & 0b11111111111;

        } else if (isDec(args[1])) {

            code |= Integer.parseInt(args[1]) & 0b11111111111;

        } else if (isLabel(args[1])) {

            int labelPc = labels.get(args[1]);

            int diff = labelPc - pc;

            code |= diff & 0b11111111111;

        } else {
            throw new IllegalArgumentException("Expected immediate or label, got: " + args[1]);
        }

        return code;
    }

    private static short parseEnableImmediate(String[] args, int pc, Map<String, Integer> labels) {
        short code = 0;

        if (args.length != 3) {
            throw new IllegalArgumentException("Expected 2 arguments: " + Arrays.toString(args));
        }

        if (!isDec(args[1])) {
            throw new IllegalArgumentException("Expected 0 or 1, got: " + args[1]);
        }

        int en = Integer.parseInt(args[1]);

        if (en < 0 || en > 1) {
            throw new IllegalArgumentException("Expected 0 or 1, got: " + args[1]);
        }

        code |= en << 10;

        if (isHex(args[2])) {

            code |= Integer.parseInt(args[2].replaceAll("0x", ""), 16) & 0b1111111111;

        } else if (isDec(args[2])) {

            code |= Integer.parseInt(args[2]) & 0b1111111111;

        } else if (isLabel(args[2])) {

            int labelPc = labels.get(args[2]) & 0b1111111111;

            int diff = labelPc - pc;

            code |= diff & 0b1111111111;

        } else {
            throw new IllegalArgumentException("Expected immediate or label, got: " + args[2]);
        }

        return code;
    }

    private static short parseByType(String[] args, int pc, Map<String, Integer> labels) {

        String name = args[0];

        switch (name) {
            case "NOP":
            case "SYN":
                return 0;
            case "HALT":
                return 1;
            case "SR0":
            case "SR1":
            case "SR2":
            case "SR3":
            case "SFC":
                return parseRegisterImmediate(args, pc, labels);
            case "LDE":
            case "STE":
            case "INCC":
                return parseDoubleRegister(args, pc, labels);
            case "BP":
                return parseImmediate(args, pc, labels);
            case "SPM":
                return parseSingleRegister(args, pc, labels);
            case "SME":
                return parseEnableImmediate(args, pc, labels);
        }

        throw new IllegalArgumentException("Unrecognized instruction: " + name);

    }

    private static byte getOpCode(String name) {

        switch (name) {
            case "NOP":
                return 0b00000;
            case "HALT":
                return 0b00001;
            case "SR0":
                return 0b00100;
            case "SR1":
                return 0b00101;
            case "SR2":
                return 0b00110;
            case "SR3":
                return 0b00111;
            case "LDE":
                return 0b01000;
            case "STE":
                return 0b01001;
            case "INCC":
                return 0b01010;
            case "BP":
                return 0b01011;
            case "SFC":
                return 0b01100;
            case "SPM":
                return 0b01101;
            case "SME":
                return 0b01110;
            case "SYN":
                return 0b01111;
        }

        throw new IllegalArgumentException("Unrecognized instruction: " + name);

    }

}
