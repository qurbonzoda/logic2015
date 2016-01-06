package utils;

/**
 * Created by qurbonzoda on 05.01.16.
 */
public abstract class BinaryOperator implements Expression {
    private final Operator operator;
    private final Expression leftOperand, rightOperand;
    public BinaryOperator(Operator operator, Expression leftOperand, Expression rightOperand) {
        System.err.println("new binOperator: " + "(" + leftOperand.toString() + operator.toString() + rightOperand.toString() + ")");
        this.operator = operator;
        this.leftOperand = leftOperand;
        this.rightOperand = rightOperand;
    }

    public Operator getOperator() {
        return operator;
    }

    public Expression getLeftOperand() {
        return leftOperand;
    }

    public Expression getRightOperand() {
        return rightOperand;
    }

    @Override
    public boolean equals(Object o) {
        if (!(o instanceof BinaryOperator)) {
            return false;
        }
        BinaryOperator binOperator = (BinaryOperator) o;
        return operator.equals(binOperator.operator)
                && leftOperand.equals(binOperator.leftOperand)
                && rightOperand.equals(binOperator.rightOperand);
    }

    @Override
    public String toString() {
        return "(" + leftOperand.toString() + operator.toString() + rightOperand.toString() + ")";
    }
}
