package utils;

/**
 * Created by qurbonzoda on 06.01.16.
 */
public enum Annotation {

    AXIOM_SCHEMES("Сх. акс."), ASSUMPTION("Предп."), MP("M.P."), NOT_PROVED("Не доказано");

    private final String value;

    private Annotation(String value) {
        this.value = value;
    }

    @Override
    public String toString() {
        return value;
    }
}
