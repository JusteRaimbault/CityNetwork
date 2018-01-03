package org.nlogo.extensions.numanal;

import org.nlogo.api.LogoException;
import org.nlogo.api.ExtensionException;
import org.nlogo.api.Argument;
import org.nlogo.api.Syntax;
import org.nlogo.api.Context;
import org.nlogo.api.DefaultReporter;
import org.nlogo.api.ReporterTask;

public class BrentRoot extends DefaultReporter {
    /*
     * BrentRoot employs the Brent alorithm to find the root (zero) of
     * a function of one variable, x. The return value is the value of x 
     * at the root.
     * 
     * The arguments are:
     * fnctn - the function, passed as a NetLogo task variable.
     * a and b - the bounds between which the root is to be 
     * found. Note that if the range between the two bounds does not contain
     * a root of the function, that is if the function evaluated at x = a
     * does not have a different sign than the function evaluated at
     * x = b, then an exception is thrown. (It might be useful at some point
     * to add a bounds-finding routine that would allow a single initial 
     * guess or that would fix invalid bounds.)
     * tol - the tolerance to which the solution is taken, as a proportion of
     * x at the root. If the root occurs very close to x = 0, the 
     * tolerance is set to a small, positive number.
     */

    @Override
    public Syntax getSyntax() {
        return Syntax.reporterSyntax(new int[]{Syntax.WildcardType(),
                    Syntax.NumberType(), Syntax.NumberType(),
                    Syntax.NumberType()}, Syntax.NumberType());
    }

    @Override
    public Object report(Argument args[], Context context)
            throws ExtensionException, LogoException {

        final double SQRT_DBL_EPSILON = Math.sqrt(Double.MIN_NORMAL);
        final int MAX_STEPS = 1000;

        ReporterTask fnctn = args[0].getReporterTask();
        double a = args[1].getDoubleValue();
        double b = args[2].getDoubleValue();
        double tol = args[3].getDoubleValue();

        // Evaluate the function at its bounds and make sure that it 
        // brackets zero.
        double fa = NumAnalExtension.GetFofX(a, fnctn, context);
        double fb = NumAnalExtension.GetFofX(b, fnctn, context);
        if ((fa > 0.0 && fb > 0.0) || (fa < 0.0 && fb < 0.0)) {
            throw new ExtensionException("Brent-root: " + a 
                    + " and " + b + " do not bracket the root.");
        }
        
        double c = b;
        double fc = fb;
        double d = b - a;
        double e = d;
        
        for (int iter = 0; iter < MAX_STEPS; iter++) {
            if ((fb > 0.0 && fc > 0.0) || (fb < 0.0 && fc < 0.0)) {
                // Need to rename a, b and c.
                c = a;
                fc = fa;
                d = b - a;
                e = d;
            }
            if (Math.abs(fc) < Math.abs(fb)) {
                a = b;
                fa = fb;
                b = c;
                fb = fc;
                c = a;
                fc = fa;
            }
            
            // Check for convergence to a root.
            double tol1 = SQRT_DBL_EPSILON + Math.abs(b) * tol;
            double xmid = 0.5 * (c - b);
            if (Math.abs(xmid) <= tol1 || fb == 0.0) {
                return (b);
            }
            
            // Otherwise try inverse quadratic interpolation.
            double p, q;
            if (Math.abs(e) >= tol1 && Math.abs(fa) >= Math.abs(fa)) {
                double s = fb / fa;
                if (a == c) {
                    p = 2.0 * xmid * s;
                    q = 1.0 - s;
                } else {
                    q = fa / fc;
                    double r = fb / fc;
                    p = s * (2.0 * xmid * q * (q - r) - (b - a) * (r - 1.0));
                    q = (q - 1.0) * (r - 1.0) * (s - 1.0);
                }
                if (p > 0.0) {
                    q = -q;
                }
                p = Math.abs(p);
                double min1 = 3.0 * xmid * q - Math.abs(tol1 * q);
                double min2 = Math.abs(e * q);
                if (2.0 * p < Math.min(min1, min2)) {
                    // Interpolate
                    e = d;
                    d = p / q;
                } else {
                    // No luck, try bisection instead.
                    d = xmid;
                    e = d;
                }
            } else {
                // Convergence is too slow, just do a bisection.
                d = xmid;
                e = d;
            }

            // Move best guess to a.
            a = b;
            fa = fb;
            b += (Math.abs(d) > tol1) ? d : tol1 * ((xmid < 0.0) ? -1 : 1);
            fb = NumAnalExtension.GetFofX(b, fnctn, context);
        }
        
        // We're out of the loop. Too many iterations.
        throw new ExtensionException("Brent-root: Exceeded the maximum number"
                + " of steps: " + MAX_STEPS);
    }
}
