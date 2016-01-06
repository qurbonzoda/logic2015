package utils;

/**
 * Created by qurbonzoda on 05.01.16.
 */
public class Disjunction extends BinaryOperator implements Expression {
    public Disjunction(Expression leftOperand, Expression rightOperand) {
        super(Operator.DISJ, leftOperand, rightOperand);
    }
}
