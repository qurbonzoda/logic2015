package utils;

/**
 * Created by qurbonzoda on 05.01.16.
 */
public class Negation implements Expression {
    final Expression operand;
    public Negation(Expression operand) {
        System.err.println("new negation: !(" + operand.toString() + ")");
        this.operand = operand;
    }

    public Expression getOperand() {
        return operand;
    }

    @Override
    public boolean equals(Object o) {
        if (!(o instanceof  Negation)) {
            return false;
        }
        Negation negation = (Negation) o;
        return operand.equals(negation.operand);
    }

    @Override
    public String toString() {
        return "!" + operand.toString();
    }
}
