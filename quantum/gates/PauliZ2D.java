package quantum.gates;

import math.Complex;

public class PauliZ2D extends Gate{
    public PauliZ2D(){
        dimension = 2;
        matrix = new Complex[][]{
                {new Complex(1), new Complex(0)},
                {new Complex(0), new Complex(-1)}};
    }
}
