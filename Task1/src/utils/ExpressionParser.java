package utils;

import java.util.function.Supplier;

/**
 * Created by qurbonzoda on 05.01.16.
 */
public class ExpressionParser {
    private static String expression;
    private static int pos, length;
    private static char curChar;

    public static Expression parse(String expression) {
        ExpressionParser.expression = expression;
        length = expression.length();
        pos = 0;
        readNextChar();
        return parseImplication();
    }

    private static void readNextChar() {
        StackTraceElement[] element = Thread.currentThread().getStackTrace();
        //System.err.println("readNextChar from: " + element[element.length - 1]);
        curChar = (pos >= length ? '\0' : expression.charAt(pos++));
    }

    private static Expression parseImplication() {
        return parseFor(parseDisjunction(), ExpressionParser::parseImplication, Operator.IMPL);
    }
    private static Expression parseDisjunction() {
        return parseFor(parseConjunction(), ExpressionParser::parseConjunction, Operator.DISJ);
    }
    private static Expression parseConjunction() {
        return parseFor(parseUnary(), ExpressionParser::parseUnary, Operator.CONJ);

    }

    private static Expression parseUnary() {
        Expression result = null;
        if (Character.isLetter(curChar)) {
            result = readVariable();
            readNextChar();
        } else if (curChar == '(') {
            readNextChar();
            result = parseImplication();
            if (curChar != ')') {
                throw new RuntimeException("Bracket not closed");
            }
            readNextChar();
        } else if (curChar == '!') {
            readNextChar();
            result = new Negation(parseUnary());
        } else {
            throw new IllegalArgumentException("Unexpected symbol at " + pos + " of " + expression);
        }
        return result;
    }

    private static Variable readVariable() {
        int leftNumBorder = pos - 1;
        int rightNumBorder = -1;
        for (int i = leftNumBorder; i < length; i++) {
            if (!Character.isLetter(expression.charAt(i)) && !Character.isDigit(expression.charAt(i))) {
                rightNumBorder = i;
                break;
            }
        }
        if (rightNumBorder == -1) {
            rightNumBorder = length;
        }
        pos = rightNumBorder;
        return new Variable(expression.substring(leftNumBorder, rightNumBorder));
    }

    private static Expression parseFor(Expression result, Supplier<Expression> supplier, final Operator... operators) {
        Operator operator = Operator.buildOperator(curChar);
        while (operator != null && operator.isOperatorEquals(operators)) {
            readNextChar();
            if (operator.isOperatorEquals(Operator.IMPL)) {
                readNextChar();
            }
            result = operator.apply(result, supplier.get());
            operator = Operator.buildOperator(curChar);
        }
        return result;
    }
}
