package quantum.gates;

import math.Complex;
import quantum.Qbit;
import quantum.State;

public class Gate {
    protected int dimension;
    protected Complex[][] matrix;

    public Gate(Complex[][] matrix){
        if (matrix.length != matrix[0].length)
            throw new IllegalArgumentException("The gate must be a square matrix!");
        this.matrix = matrix;
        this.dimension = matrix.length;
    }

    protected Gate(){}

    public int getDimension(){
        return dimension;
    }
    public Complex[][] getMatrix(){return matrix;}

    public void apply(Qbit input) {
        if (dimension > 2)
            throw new IllegalArgumentException("This gate can be applied to " + (Math.log(dimension)/Math.log(2)) + " Qbits!");
        Complex newProb0 = Complex.sum(Complex.multiply(input.getComponent(0), matrix[0][0]), Complex.multiply(input.getComponent(1), matrix[0][1]));
        Complex newProb1 = Complex.sum(Complex.multiply(input.getComponent(0), matrix[1][0]), Complex.multiply(input.getComponent(1), matrix[1][1]));
        input.setComponent(0, newProb0);
        input.setComponent(1, newProb1);
    }

    public void apply(State input){
        if (input.getNumOfComponents() != dimension)
            throw new IllegalArgumentException("This gate can be applied to " + (Math.log(dimension)/Math.log(2)) + " Qbits!");

        Complex[] result = new Complex[dimension];
        for (int i = 0; i < result.length; i++)
            result[i] = new Complex(0);

        //This is just matrix multiplication
        for (int i = 0; i < dimension; i++)
            for (int j = 0; j < dimension; j++)
                result[i].add(Complex.multiply(input.getComponent(j), matrix[i][j]));

        for (int i = 0; i < dimension; i++)
            input.setComponent(i, result[i]);
    }
}
