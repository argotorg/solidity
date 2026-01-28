import org.antlr.v4.runtime.*;
import java.io.*;
import java.nio.file.*;

public class AntlrBatchTestRig {
    public static void main(String[] args) throws Exception {
        if (args.length < 1) {
            System.err.println("Usage: AntlrBatchTestRig <file1> [file2] ...");
            System.exit(1);
        }

        int exitCode = 0;
        for (String filePath: args) {
            try {
                if (!testFile(filePath))
                    exitCode = 1;
            } catch (Exception e) {
                System.err.println("ERROR:" + filePath + ":" + e.getMessage());
                exitCode = 1;
            }
        }
        System.exit(exitCode);
    }

    private static boolean testFile(String filePath) throws Exception {
        // Detect mode based on file extension
        String mode = filePath.endsWith(".yul") ? "yul" : "sol";
        String content = new String(Files.readAllBytes(Paths.get(filePath)));

        // Check if file expects parser error
        boolean expectsError = content.contains("// ParserError");

        CharStream input;
        if (mode.equals("sol")) {
            // Remove ExternalSource lines for Solidity files
            content = content.replaceAll("(?m)^==== ExternalSource:.*$", "");
            input = CharStreams.fromString(content);
        } else {
            // Wrap Yul in assembly statement
            input = CharStreams.fromString("assembly " + content);
        }

        SolidityLexer lexer = new SolidityLexer(input);
        CommonTokenStream tokens = new CommonTokenStream(lexer);
        SolidityParser parser = new SolidityParser(tokens);

        // Remove default error listeners and add custom one
        parser.removeErrorListeners();
        lexer.removeErrorListeners();

        ErrorCollector errorCollector = new ErrorCollector();
        parser.addErrorListener(errorCollector);
        lexer.addErrorListener(errorCollector);

        // Parse based on mode
        if (mode.equals("sol")) {
            parser.sourceUnit();
        } else {
            parser.assemblyStatement();
        }

        boolean hasErrors = errorCollector.hasErrors();

        // Output result
        if (expectsError) {
            if (hasErrors) {
                System.out.println("PASS:" + filePath + ":FAILED_AS_EXPECTED");
            } else {
                System.out.println("FAIL:" + filePath + ":SUCCEEDED_DESPITE_PARSER_ERROR");
                return false;
            }
        } else {
            if (!hasErrors) {
                System.out.println("PASS:" + filePath + ":OK");
            } else {
                System.out.println("FAIL:" + filePath + ":" + errorCollector.getErrors());
                return false;
            }
        }
        return true;
    }

    static class ErrorCollector extends BaseErrorListener {
        private StringBuilder errors = new StringBuilder();
        private boolean hasErrors = false;

        @Override
        public void syntaxError(Recognizer<?, ?> recognizer, Object offendingSymbol,
                              int line, int charPositionInLine,
                              String msg, RecognitionException e) {
            hasErrors = true;
            errors.append("line ").append(line).append(":").append(charPositionInLine)
                  .append(" ").append(msg).append("\n");
        }

        public boolean hasErrors() {
            return hasErrors;
        }

        public String getErrors() {
            return errors.toString();
        }
    }
}
