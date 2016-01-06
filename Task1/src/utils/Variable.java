package utils;

import sun.rmi.runtime.Log;

/**
 * Created by qurbonzoda on 05.01.16.
 */
public class Variable implements Expression {
    final String name;
    public Variable(String name) {
        System.err.println("new var: " + name);
        this.name = name;
    }
    @Override
    public boolean equals(Object o) {
        if (!(o instanceof Variable)) {
            return false;
        }
        Variable variable = (Variable) o;
        return name.equals(variable.name);
    }
    @Override
    public String toString() {
        return name;
    }
}
