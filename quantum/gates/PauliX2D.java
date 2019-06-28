package quantum.gates;

import math.Complex;

public class PauliX2D extends Gate{
    public PauliX2D(){
        dimension = 2;
        matrix = new Complex[][]{
                {new Complex(0 ), new Complex(1)},
                {new Complex(1 ), new Complex(0)}};
    }
}
