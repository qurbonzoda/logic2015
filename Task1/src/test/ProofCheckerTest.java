package test;

import org.junit.Before;
import org.junit.Test;
import solution.ProofChecker;

public class ProofCheckerTest {

    ProofChecker proofChecker;


    @Before
    public void getInstance() {
        proofChecker = new ProofChecker();
    }

    @Test
    public void test1() {
        proofChecker.check("/home/qurbonzoda/MatLog/logic2015/Task1/src/test/test1", "/home/qurbonzoda/MatLog/logic2015/Task1/src/test/test1.out");
    }
    @Test
    public void test2() {
        proofChecker.check("/home/qurbonzoda/MatLog/logic2015/Task1/src/test/test2", "/home/qurbonzoda/MatLog/logic2015/Task1/src/test/test2.out");
    }

}