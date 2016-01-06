package utils;

/**
 * Created by qurbonzoda on 05.01.16.
 */
public enum Operator {
    IMPL('-') {
        @Override
        public Expression apply(final Expression leftOperand, final Expression rightOperand) {
            return new Implication(leftOperand, rightOperand);
        }

    },
    CONJ('&') {
        @Override
        public Expression apply(final Expression leftOperand, final Expression rightOperand) {
            return new Conjunction(leftOperand, rightOperand);
        }
    },
    DISJ('|') {
        @Override
        public Expression apply(final Expression leftOperand, final Expression rightOperand) {
            return new Disjunction(leftOperand, rightOperand);
        }
    };
    private final char code;

    Operator(final char code) {
        this.code = code;
    }

    @Override
    public String toString() {
        if (code == '-') {
            return "->";
        }
        return String.valueOf(code);
    }

    public static Operator buildOperator(final char code) {
        for (Operator operator: Operator.values()) {
            if (code == operator.code) {
                return operator;
            }
        }
        return null;
    }

    public boolean isOperatorEquals(final Operator... operators) {
        for (Operator operator: operators) {
            if (this.equals(operator)) {
                return true;
            }
        }
        return false;
    }

    public abstract Expression apply(final Expression leftOperand, final Expression rightOperand);
}
