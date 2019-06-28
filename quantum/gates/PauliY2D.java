package quantum.gates;

import math.Complex;

public class PauliY2D extends Gate{
    public PauliY2D(){
        dimension = 2;
        matrix = new Complex[][]{
                {new Complex(0), new Complex(1, 3 * Math.PI / 2)},
                {new Complex(1, Math.PI / 2), new Complex(0)}};
    }
}
