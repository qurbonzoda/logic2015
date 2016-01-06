package utils;

/**
 * Created by qurbonzoda on 05.01.16.
 */
public class Conjunction extends BinaryOperator implements Expression {
    public Conjunction(Expression leftOperand, Expression rightOperand) {
        super(Operator.CONJ, leftOperand, rightOperand);
    }
}
