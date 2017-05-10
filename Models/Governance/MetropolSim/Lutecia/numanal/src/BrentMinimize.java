package org.nlogo.extensions.numanal;

import org.nlogo.api.LogoException;
import org.nlogo.api.ExtensionException;
import org.nlogo.api.Argument;
import org.nlogo.api.Syntax;
import org.nlogo.api.Context;
import org.nlogo.api.DefaultReporter;
import org.nlogo.api.ReporterTask;

public class BrentMinimize extends DefaultReporter {
    /*
     * BrentMinimize employs the Brent alorithm to minimize a function 
     * of one variable, x. The return value is the value of x between an upper
     * and lower bound where the function takes on its minimum value. 
     * The arguments are:
     * fnctn - the function to be minimized, passed as a NetLogo task variable.
     * lowBound and highBound - the bounds between which the minimum is to be 
     * found. Note that if the range between the two bounds does not contain
     * the "true" minimum of the function, the algorithm returns the bound 
     * closest to the minimim.
     * tol - the tolerance to which the solution is taken, as a proportion of
     * x. If the minimum occurs very close to x = 0, the tolerance is set to 
     * a small, positive number.
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

        // Calculate the Golden Ratio (approximately 0.3819660) and the 
        // square root of the precision for doubles. Set the maximum 
        // number of steps allowed.
        final double GOLDR = 0.5 * (3.0 - Math.sqrt(5.0));
        final double SQRT_DBL_EPSILON = Math.sqrt(Double.MIN_NORMAL);
        final int MAX_STEPS = 1000;

        ReporterTask fnctn = args[0].getReporterTask();
        double lowBound = args[1].getDoubleValue();
        double highBound = args[2].getDoubleValue();
        double tol = args[3].getDoubleValue();

        // Make sure that the lower and upper bounds are in ascending order.
        if (lowBound > highBound) {
            double temp = lowBound;
            lowBound = highBound;
            highBound = temp;
        }
        /*
         * x is the initial point in any step, the best point found so far, 
         * or the most recent one in case of a tie. 
         * w is the second best point.
         * v is the previous value of w.
         * u is the point that was most recently evaluated. In general,
         * u = x + d, where d is the distance moved in the current step,
         * either through a golden section or a parabolic fit.
         */
        double x = lowBound + GOLDR * (highBound - lowBound);
        double v = x;
        double w = x;
        double fx = NumAnalExtension.GetFofX(x, fnctn, context);
        double fw = fx;
        double fv = fx;
        double e = 0.0;
        double d = 0.0;

        for (int i = 0; i < MAX_STEPS; i++) {
            double midPt = 0.5 * (lowBound + highBound);
            double tol1 = SQRT_DBL_EPSILON + Math.abs(x) * tol;
            double tol2 = 2.0 * tol1;
            // Check stopping criterion. If it is satisfied, return the 
            // current best point.
            if (Math.abs(x - midPt) <= (tol2 - 0.5 * (highBound - lowBound))) {
                return x;
            }

            double u = 0.0;
            double fu = 0.0;
            if (Math.abs(e) > tol1) {
                // Fit a parabola through x, w and v, and check to see if 
                // it fits well.
                double r = (x - w) * (fx - fv);
                double q = (x - v) * (fx - fw);
                double p = ((x - v) * q) - ((x - w) * r);
                q = 2.0 * (q - r);
                p = (q > 0.0) ? -p : p;
                q = Math.abs(q);
                double etemp = e;
                e = d;
                if ((Math.abs(p) >= Math.abs(0.5 * q * etemp))
                        || (p <= q * (lowBound - x))
                        || (p >= q * (highBound - x))) {
                    // The parabola does not fit well. Use a golden section
                    // step instead.
                    e = (x >= midPt) ? (lowBound - x) : (highBound - x);
                    d = GOLDR * e;
                } else {
                    // The parabola fits well enough, use a parabolic 
                    // interpolation step.
                    d = p / q;
                    u = x + d;
                    // fnctn must not be evaluated too close to the 
                    // boundaries. Shorten the step if necessary.
                    if ((u - lowBound) < tol2 || (highBound - u) < tol2) {
                        d = (midPt > x) ? tol1 : -tol1;
                    }

                }
            } else {
                // Go straight to a golden section step.
                e = (x >= midPt) ? (lowBound - x) : (highBound - x);
                d = GOLDR * e;
            }
            // Now take the step of distance, d, from the current point, x, 
            // to the new point, u. Take care that d is at least
            // as great as tol1. If not, step the distance tol1 instead as
            // fnctn must not be evaluated too close to x.
            u = x + ((Math.abs(d) > +tol1) ? d : ((d > 0) ? tol1 : -tol1));

            // Evaluate the function at the new point, u.
            fu = NumAnalExtension.GetFofX(u, fnctn, context);

            // Update lowBound, highBound, v, w, and x
            if (fu <= fx) {
                // The new point is at least as good as the old. Make 
                // the old best point the new high or low bound and set x
                // to the new point.
                if (u >= x) {
                    lowBound = x;
                } else {
                    highBound = x;
                }
                v = w;
                fv = fw;
                w = x;
                fw = fx;
                x = u;
                fx = fu;
            } else {
                // The new point is worse than the old. Replace the 
                // high or low bound with the new point and enter the next
                // iteration with the same x.
                if (u < x) {
                    lowBound = u;
                } else {
                    highBound = u;
                }
                if (fu <= fw || w == x) {
                    v = w;
                    fv = fw;
                    w = u;
                    fw = fu;
                } else if (fu <= fv || v == x || v == w) {
                    v = u;
                    fv = fu;
                }
            }
        }
        
        // Too many steps. Throw an exception.
        throw new ExtensionException(
                "Brent-minimize: Exceeded the maximum number of steps: "
                + MAX_STEPS);
    }

}
