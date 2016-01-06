package solution;

import utils.*;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Scanner;

/**
 * Created by qurbonzoda on 06.01.16.
 */
public class ProofChecker {

    private ArrayList<Expression> assumptions;
    private Expression statement;
    private ArrayList<Expression> formulas;
    private static ArrayList<Expression> axioms;
    private Scanner scanner;
    private PrintWriter printer;

    public static final String pathToAxioms = "/home/qurbonzoda/MatLog/logic2015/Task1/src/axioms.txt";
    public static final String eliminatingRegex = "[ \r\t]";

    static {
        axioms = new ArrayList<>();
        try (Scanner scanner = new Scanner(Paths.get(pathToAxioms))){
            while (scanner.hasNext()) {
                axioms.add(ExpressionParser.parse(scanner.nextLine()));
            }
        } catch (IOException e) {
            throw new IllegalArgumentException(e);
        }
    }

    private void init(String pathToInput, String pathToOutput) {
        try {
            scanner = new Scanner(Paths.get(pathToInput));
            printer = new PrintWriter(new File(pathToOutput));
            formulas = new ArrayList<>();
            assumptions = new ArrayList<>();

            String header = scanner.nextLine().replaceAll(eliminatingRegex, "");
            String[] exp = header.split(",");

            int j = exp[ exp.length - 1 ].indexOf("|-");

            String toProve = exp[ exp.length - 1 ].substring(j + 2);
            exp[ exp.length - 1 ] = exp[ exp.length - 1 ].substring(0, j);

            statement = ExpressionParser.parse(toProve);
            for (String s : exp) {
                if (!s.isEmpty()) {
                    assumptions.add(ExpressionParser.parse(s));
                }
            }
            while (scanner.hasNext()) {
                String formula = scanner.nextLine();
                formula = formula.replaceAll(eliminatingRegex, "");
                formulas.add(ExpressionParser.parse(formula));
            }
        } catch (IOException e) {
            throw new IllegalArgumentException(e);
        }
    }

    public void check(String pathToInput, String pathToOutput) {
        init(pathToInput, pathToOutput);
        for (int i = 0; i < formulas.size(); i++) {
            Expression formula = formulas.get(i);
            printer.printf("(%d) %s ", i + 1, formula.toString());
            int pos, poses[];
            if ((pos = isAssumption(formula)) >= 0) {
                printer.printf("(%s %d)", Annotation.ASSUMPTION, pos);
            } else if ((pos = isAxiom(formula)) >= 0) {
                printer.printf("(%s %d)", Annotation.AXIOM_SCHEMES, pos);
            } else if ((poses = isMP(i)).length != 0) {
                printer.printf("(%s %d, %d)", Annotation.MP, poses[0], poses[1]);
            } else {
                printer.printf("(%s)", Annotation.NOT_PROVED);
            }
            printer.println();
            printer.flush();
        }
    }

    private int isAssumption(Expression formula) {
        int i = 1;
        for (Expression assumption : assumptions) {
            if (assumption.toString().equals(formula.toString())) {
                return i;
            }
            i++;
        }
        return -1;
    }

    private int isAxiom(Expression formula) {
        int axiomIndex = 1;
        for (Expression axiom : axioms) {
            ArrayList<String> ofAxiom = new ArrayList<>();
            ArrayList<String> ofFormula = new ArrayList<>();
            if (resemblesAxiom(axiom, formula, ofAxiom, ofFormula)) {
                boolean flag = true;
                vars:
                for (int i = 0; i < ofAxiom.size(); i++) {
                    String variable = ofAxiom.get(i);
                    String correspondence = ofFormula.get(i);
                    for (int j = 0; j < i; j++) {
                        if (variable.equals(ofAxiom.get(j)) && !correspondence.equals(ofFormula.get(j))) {
                            flag = false;
                            break vars;
                        }
                    }
                }
                if (flag) {
                    System.err.println(axiomIndex);
                    System.err.println(ofAxiom);
                    System.err.println(ofFormula);
                    return axiomIndex;
                }
            }
            axiomIndex++;
        }
        return -1;
    }

    private int[] isMP(int n) {
        Expression formula = formulas.get(n);
        for (int i = 0; i < n; i++) {
            if (formulas.get(i) instanceof Implication) {
                Implication implication = (Implication) formulas.get(i);
                if (implication.getRightOperand().equals(formula)) {
                    for (int j = 0; j < n; j++) {
                        if (formulas.get(j).equals(implication.getLeftOperand())) {
                            return new int[]{j + 1, i + 1};
                        }
                    }
                }
            }
        }
        return new int[]{};
    }

    private boolean resemblesAxiom(Expression axiom, Expression formula, ArrayList<String> ofAxiom, ArrayList<String> ofFormula) {
        if (axiom instanceof Variable) {
            ofAxiom.add(axiom.toString());
            ofFormula.add(formula.toString());
            return true;
        } else if ((axiom instanceof Negation) && (formula instanceof Negation)) {
            return resemblesAxiom(((Negation) axiom).getOperand(), ((Negation) formula).getOperand(), ofAxiom, ofFormula);
        } else if ((axiom instanceof BinaryOperator) && (formula instanceof BinaryOperator)) {
            BinaryOperator binAxiom = (BinaryOperator) axiom;
            BinaryOperator binFormula = (BinaryOperator) formula;
            return binAxiom.getOperator() == binFormula.getOperator()
                    && resemblesAxiom(binAxiom.getLeftOperand(), binFormula.getLeftOperand(), ofAxiom, ofFormula)
                    && resemblesAxiom(binAxiom.getRightOperand(), binFormula.getRightOperand(), ofAxiom, ofFormula);
        } else {
            return false;
        }
    }
}
