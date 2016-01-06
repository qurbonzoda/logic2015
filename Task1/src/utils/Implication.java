package utils;

/**
 * Created by qurbonzoda on 05.01.16.
 */
public class Implication extends BinaryOperator implements Expression {
    public Implication(Expression leftOperand, Expression rightOperand) {
        super(Operator.IMPL, leftOperand, rightOperand);
    }
}
