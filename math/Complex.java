package math;

public class Complex {
    private double modulus;
    private double theta;

    //Because we're dealing with irrational numbers,
    // we must round extremely small numbers to zero for results' sake
    private final static double SMALLEST_DELTA = 0.000000000000001;

    public Complex(double modulus, double theta){
        this.modulus = Math.abs(modulus);
        this.theta = (modulus < 0)? Math.PI + theta % (2*Math.PI) : theta % (2*Math.PI);
    }

    public Complex(double modulus){
        this.modulus = Math.abs(modulus);
        this.theta = (modulus < 0)? Math.PI : 0;
    }

    @Override
    public String toString() {
        if (getImaginaryPart() == 0)
            return String.valueOf(getRealPart());
        return getRealPart() + " " + getImaginaryPart() + "i";
    }

    public double getModulus(){return modulus;}
    public void setModulus(double newMod){modulus = newMod;}
    public double getTheta(){return theta;}
    public void setTheta(double newTheta){theta = newTheta;}

    public double getRealPart(){
        if (Math.abs(modulus * Math.cos(theta)) > SMALLEST_DELTA)
            return modulus * Math.cos(theta);
        else
            return 0;
    }

    public double getImaginaryPart(){
        if (Math.abs(modulus * Math.sin(theta)) > SMALLEST_DELTA)
            return modulus * Math.sin(theta);
        else
            return 0;
    }

    public Complex pow(double n){
        modulus = Math.pow(modulus, n);
        theta = (theta * n) % Math.PI;
        return this;
    }

    public static Complex pow(Complex input, int pow){
        double newModulus = Math.pow(input.modulus, pow);
        double newTheta = (input.theta * pow) % Math.PI;
        return new Complex(newModulus, newTheta);
    }

    public Complex add(Complex n){
        double realPart = getRealPart() + n.getRealPart();
        double imaginaryPart = getImaginaryPart() + n.getImaginaryPart();
        modulus = Math.sqrt(Math.pow(realPart, 2) + Math.pow(imaginaryPart, 2));
        double theta;
        if (realPart == 0)
            theta = imaginaryPart > 0? Math.PI/2 : 3 * Math.PI / 2;
        else if (imaginaryPart == 0)
            theta = realPart > 0 ? 0 : Math.PI;
        else
            theta = Math.atan(imaginaryPart / realPart);
        this.theta = theta;
        return this;
    }

    public static Complex sum(Complex n1, Complex n2){
        double realPart = n1.getRealPart() + n2.getRealPart();
        double imaginaryPart = n1.getImaginaryPart() + n2.getImaginaryPart();
        double modulus = Math.sqrt(Math.pow(realPart, 2) + Math.pow(imaginaryPart, 2));
        double theta;
        if (realPart == 0)
            theta = imaginaryPart > 0? Math.PI/2 : 3 * Math.PI / 2;
        else if (imaginaryPart == 0)
            theta = realPart > 0 ? 0 : Math.PI;
        else
            theta = Math.atan(imaginaryPart / realPart);
        return new Complex(modulus, theta);
    }

    public Complex multiplyBy(Complex n){
        modulus *= n.getModulus();
        theta += n.getTheta();
        return this;
    }

    public static Complex multiply(Complex n1, Complex n2){
        Complex result = new Complex(0, 0);
        result.modulus = n1.getModulus() * n2.getModulus();
        result.theta = n1.getTheta() + n2.getTheta();
        return result;
    }

    public Complex divideBy(Complex n){
        modulus /= n.getModulus();
        theta -= n.getTheta();
        return this;
    }

    public Complex divideBy(double n){
        modulus /= n;
        return this;
    }

    public static Complex divide(Complex n1, Complex n2){
        double modulus = n1.getModulus() / n2.getModulus();
        double theta = n1.getTheta() - n2.getTheta();
        return new Complex(modulus, theta);
    }

    public static Complex divide(Complex n1, double n2){
        double modulus = n1.getModulus() / n2;
        double theta = n1.getTheta();
        return new Complex(modulus, theta);
    }

    @Override
    public boolean equals(Object obj) {
        if (!(obj instanceof Complex))
            return false;
        return ((Complex)obj).modulus == modulus && ((Complex)obj).theta == theta;
    }
}