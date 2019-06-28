package quantum;

import math.Complex;

import quantum.gates.Gate;
import quantum.gates.ID;

import java.util.*;

public class State {
    protected Complex[] components;

    public State(Qbit[] qbits){
        components = tensorize(qbits);
    }

    protected State() {}

    public int measureQbit(int n){
        //We get a |0> or |1> value for out qbit based on it's probabilities.
        Random rnd = new Random();
        Qbit myQbit = measuredQbits()[n];
        float randomFloat = rnd.nextFloat();
        char result;
        if (randomFloat < Complex.pow(myQbit.probabilityOf0(), 2).getRealPart())
            result = '0';
        else
            result = '1';

        //We erase all states that don't coincide with our measurement,
        // and also collect the total probability to be used in the next part.
        double totalProbability = 0;
        for (int i = 0; i < components.length; i++)
            if(fullBinaryString(i).charAt(n) != result)
                components[i] = new Complex(0);
            else
                totalProbability += Math.pow(components[i].getModulus(), 2);

        //We set new amplitudes based on relative probabilities of the remaining states.
        for (int i = 0; i < components.length; i++)
            components[i].divideBy(Math.sqrt(totalProbability));

        return result=='0' ? 0 : 1;
    }

    public void printAmplitudes(){
        StringBuilder builder = new StringBuilder();
        builder.append("MEASURE: ");
        for (int i = 0; i < components.length; i++){
            if (Complex.pow(components[i], 2).equals(new Complex(0)))
                continue;
            builder.append('|');
            builder.append(fullBinaryString(i));
            builder.append(">: ");
            //builder.append(Complex.pow(components[i], 2).toString());
            builder.append(components[i].getRealPart());
            if (i != components.length-1) builder.append(" - ");
        }
        if (builder.charAt(builder.length()-1) == ' '){
            builder.delete(builder.length()-3, builder.length()-1);
        }
        System.out.println(builder.toString());
    }

    public Complex getComponent(int n){
        return components[n];
    }

    public void setComponent(int n, Complex newVal){
        components[n] = newVal;
    }

    public int getNumOfComponents(){
        return components.length;
    }

    public int getNumberOfQbits(){return (int)(Math.log(components.length)/Math.log(2));}

    public void applyGateToQbit(int n, Gate gate){
        if (gate.getDimension() > 2)
            throw new IllegalArgumentException("This method can only be used with single-qbit gates!");
        //In order to apply a gate to a single Qbit, we must apply to the whole state a new gate,
        //which will be the result of a tensor product between the original gate and a bunch of Identity gates for the
        //Qbits what the gate should not apply to.
        //eg. To apply X gate to the second qbit in a state with 4 qbits, we do the following tensor product:
        // ID x X x ID x ID
        //Ad then apply the resulting matrix(as a Gate) to the whole state.
        Gate[] gates = new Gate[getNumberOfQbits()];
        for (int i = 0; i < gates.length; i++) gates[i] = new ID();
        gates[n] = gate;
        Gate resultingGate = kroeneckerProductForGates(gates);
        resultingGate.apply(this);
    }

    public void applyGateToQbits(int firstQbit, int lastQbit, Gate gate){
        if (gate.getDimension() != (int)Math.pow(2, lastQbit-firstQbit + 1))
            throw new IllegalArgumentException("The number of qbits does not match the gate size!");

        Gate[] gates = new Gate[getNumberOfQbits() - (lastQbit-firstQbit)];
        for (int i = 0; i < gates.length; i++) gates[i] = new ID();
        gates[firstQbit] = gate;
        Gate resultingGate = kroeneckerProductForGates(gates);
        resultingGate.apply(this);
    }

    public Qbit[] measuredQbits(){
        if ((Math.log(components.length)/Math.log(2)) % 1 != 0)
            throw new IllegalArgumentException("The components tensor must have a number of elements equal to a power of 2!");

        int numberOfQbits = (int)(Math.log(components.length)/Math.log(2));
        Qbit[] result = new Qbit[numberOfQbits];
        for (int i = 0; i < result.length; i++)
            result[i] = new Qbit(0, 0);

        //System.out.println("deTensorizing, components:");
//        for (int j = 0; j < components.length; j++) {
//            System.out.println(components[j]);
//        }
        for (int j = 0; j < numberOfQbits; j++){
            boolean isAddingZero = true;
            for (int i = 0; i < components.length; i++){
                if (isAddingZero)
                    result[numberOfQbits -1 - j].components[0].add(components[i]);//TODO: Should we be adding modulus? YES, THE ANSWER IS YES
                else
                    result[numberOfQbits -1 - j].components[1].add(components[i]);
                if ((i+1) % Math.pow(2, j) == 0){
                    isAddingZero = !isAddingZero;
                }
            }
            Complex zeroSum = result[numberOfQbits -1 - j].components[0];
            Complex oneSum = result[numberOfQbits -1 - j].components[1];
            result[numberOfQbits -1 - j].components[0] = Complex.divide(zeroSum, Complex.sum(zeroSum, oneSum)).pow(1.0/2);
            result[numberOfQbits -1 - j].components[1] = Complex.divide(oneSum, Complex.sum(zeroSum, oneSum)).pow(1.0/2);
        }
        //System.out.println("deTensorized, Result:");
//        for (int j = 0; j < result.length; j++) {
//            System.out.println(result[j].toString());
//        }
        return result;
    }

    private static Complex[] tensorize(Qbit[] input){
        Complex[][] complexInput = new Complex[input.length][2];
        for (int i = 0; i < input.length; i++)
            complexInput[i] = input[i].components;
        return tensorizeRec(complexInput);
    }

    private static Complex[] tensorizeRec(Complex[][] input){
        if (input.length == 2){
            Complex[] result = new Complex[input[0].length * input[1].length];
            for (int i = 0; i < input[0].length; i++)
                for (int j = 0; j < input[1].length; j++)
                    result[i * input[1].length + j] = Complex.multiply(input[0][i], input[1][j]);
            return result;
        }
        Complex[][] toBeTensorized = new Complex[][]{
                input[0],
                tensorizeRec(Arrays.copyOfRange(input, 1, input.length))
        };
        return tensorizeRec(toBeTensorized);
    }

    private static Gate kroeneckerProductForGates(Gate[] gates){
        Queue<Complex[][]> matrices = new LinkedList<>();
        for (Gate gate: gates){
            matrices.offer(gate.getMatrix());
        }

        Complex[][] result = matrices.poll();
        while (!matrices.isEmpty()){
            Complex[][] next = matrices.poll();
            result = kroneckerProduct(result, next);
        }
        Gate resultGate = new Gate(result);
        return resultGate;
    }

    private static Complex[][] kroneckerProduct(Complex a[][], Complex b[][])
    {
        int rowa = a.length;
        int rowb = b.length;
        int cola = a[0].length;
        int colb = b[0].length;

        Complex[][] c = new Complex[rowa * rowb][cola * colb];

        //Each element of matrix a is multiplied by whole matrix b and stored in matrix c
        for (int i = 0; i < rowa; i++)
            for (int j = 0; j < cola; j++)
                for (int k = 0; k < rowb; k++)
                    for (int l = 0; l < colb; l++)
                        c[i*rowb + k][colb*j + l] = Complex.multiply(a[i][j], b[k][l]);

        return c;
    }

    //This method adds the corresponding number of zeroes to the left of the
    // binary representation of a number according to the number of qbits in the state.
    //Eg. if we have 3 qbits, the binary representation of 1 will be "001" rather than "1"
    private String fullBinaryString(int n){
        StringBuilder builder = new StringBuilder();
        for (int j = 0; j < Math.abs(Integer.toBinaryString(n).length() - getNumberOfQbits());j++)
            builder.append('0');
        builder.append(Integer.toBinaryString(n));
        return builder.toString();
    }

    @Override
    public boolean equals(Object obj) {
        if (!(obj instanceof Qbit))
            return false;
        for (int i = 0; i < components.length; i++)
            if (!components[i].equals(((State)obj).components[i]))
                return false;
        return true;
    }
}
