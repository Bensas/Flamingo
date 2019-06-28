package quantum.gates;

import math.Complex;

public class Hadamard2d extends Gate {

    public Hadamard2d(){
        dimension = 2;
        matrix = new Complex[][]{
                {new Complex(1 / Math.sqrt(2)), new Complex(1 / Math.sqrt(2))},  // 1/sqrt(2)(1  1)
                {new Complex(1 / Math.sqrt(2)), new Complex(-1 / Math.sqrt(2))}};//          (1 -1)
    }
}