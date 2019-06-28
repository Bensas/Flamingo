package quantum.gates;

import math.Complex;

public class CNOT extends Gate{
    public CNOT(){
        dimension = 4;
        matrix = new Complex[][]{
                {new Complex(1 ), new Complex(0), new Complex(0), new Complex(0)},
                {new Complex(0 ), new Complex(1), new Complex(0), new Complex(0)},
                {new Complex(0 ), new Complex(0), new Complex(0), new Complex(1)},
                {new Complex(0 ), new Complex(0), new Complex(1), new Complex(0)}};
    }
}
