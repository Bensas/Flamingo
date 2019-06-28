package quantum;

import math.Complex;

public class Qbit extends State {

    public Qbit(Complex probabilityOf0, Complex probabilityOf1){
        components = new Complex[2];
        components[0] = probabilityOf0;
        components[1] = probabilityOf1;
    }

    public Qbit(double probabilityOf0, double probabilityOf1){
//        if (probabilityOf0 != 1 && probabilityOf1 != 1)
//            throw new IllegalArgumentException("A Qbit must be initialized to |0> or |1>");
        components = new Complex[2];
        components[0] = new Complex(probabilityOf0, 0);
        components[1] = new Complex(probabilityOf1, 0);
    }

    public Complex probabilityOf0(){
        return components[0];
    }

    public Complex probabilityOf1(){
        return components[1];
    }

    @Override
    public String toString() {
        return "[0: " + components[0].toString() + ", 1:" + components[1].toString() + "]";
    }
}