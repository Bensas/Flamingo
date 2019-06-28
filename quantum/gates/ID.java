package quantum.gates;

import math.Complex;

public class ID extends Gate {
    public ID(){
        dimension = 2;
        matrix = new Complex[][]{
                {new Complex(1 ), new Complex(0)},
                {new Complex(0 ), new Complex(1)}};
    }
}
