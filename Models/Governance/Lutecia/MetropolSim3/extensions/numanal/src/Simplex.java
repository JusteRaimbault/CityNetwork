package org.nlogo.extensions.numanal;

import org.nlogo.api.LogoException;
import org.nlogo.api.ExtensionException;
import org.nlogo.api.Argument;
import org.nlogo.api.Syntax;
import org.nlogo.api.Context;
import org.nlogo.api.DefaultReporter;
import org.nlogo.api.DefaultCommand;
import org.nlogo.api.ReporterTask;
import org.nlogo.api.LogoList;

// import java.util.Random;

/*
 * Simplex finds the minimum of a multivariate function passed to it in 
 * the task variable, fnctn, and returns list of the input values at
 * the minimum.  fnctn should be a NetLogo reporter that takes
 * a list of input values and reports the value of the function at that
 * point.  Simplex comes in two flavors: the first places no constraint 
 * on the input values; the second constrains all of the input values to 
 * be greater than or equal to zero.
 */

public class Simplex {

    /* The Simplex class contains the global parameters and the subclasses
     * that actually do the work.
     * 
     * The default values of the parameters are relatively arbitrary and
     * may be changed by the "simplex-set" primitive, and reset to their 
     * defaults by the "simplex-reset" primitive.
     *
     * Here is what they do:
     * int nrestarts_max - Specifies the desired number of restarts of the 
     * simplex procedure.  Many sources suggest a restart after the initial
     * solution is found as the initial solution may be a false minimum. This,
     * of course, will require more iterations, but given that it begins 
     * at the putative minimum, it should not require too many.  Note that 
     * the user can specify more than one restart, although it is not clear 
     * that there is any benefit for doing so.  Of course zero restarts is 
     * also possible. The default number is 1.
     * 
     * int nevals_max - insures that the procedure will not continue in an 
     * infinite loop if there is no convergence.  This sets the maximim 
     * number of evaluations of the function to be minimized and throws an 
     * ExtensionException if that number is exceeded. In the case of a 
     * restart, function evaluations are counted separately for each search.
     * 
     * int nevals_mod - when the number of evaluations reaches an approximate
     * multiple of this number, the tolerance in increased by a factor of 
     * nevals_tolfactor. This allows the routine to relax the tolerance 
     * required for a solution if the number of function evaluations grows
     * too large. By default, nevals_mod is set to (nevals_max + 1) so 
     * that the tolerance is not changed.
     * 
     * double nevals_tolfactor - the factor by which the tolerance is 
     * multiplied each nevals_mod evaluations. It must be >= 1.0.
     */
    
    static final int NRESTARTS_MAX_DEFAULT = 1;
    static final int NEVALS_MAX_DEFAULT = 10000;
    static final int NEVALS_MOD_DEFAULT = NEVALS_MAX_DEFAULT + 1;
    static final double NEVALS_TOLFACTOR_DEFAULT = 2.0;
    static final double PRANGE_DEFAULT = 0.50;
    
    static int nrestarts_max = NRESTARTS_MAX_DEFAULT;
    static int nevals_max = NEVALS_MAX_DEFAULT;
    static int nevals_mod = NEVALS_MOD_DEFAULT;
    static double nevals_tolfactor = NEVALS_TOLFACTOR_DEFAULT;
        
    /*
     * We took out the random element in creating the initial simplex as
     * with it in, NetLogo will not give reproducable results when the 
     * NetLogo random-seed is set. It appears that this is so even when 
     * the Java Random class is constructed with a fixed seed
     */
    //    static Random randgen = new Random();


    public static class SimplexSetParams extends DefaultCommand {
        /*
         * This primitive allows the user to set the simplex parameters: 
         * nrestarts_max, nevals_max, nevals_mod, and nevals_tolfactor. At  
         * least the first argument, nrestarts, must be specified. The rest of
         * the arguments are optional. if nevals_mod is not specified it 
         * defaults to nevals_max.  If nevals_tolfactor is not specified, 
         * it retains its current value. 
         */

        @Override
        public Syntax getSyntax() {
            return Syntax.commandSyntax(new int[]{
                        Syntax.NumberType() | Syntax.RepeatableType()});
        }

        @Override
        public void perform(Argument args[], Context context)
                throws ExtensionException, LogoException {

            int nargs = args.length;
            nrestarts_max = args[0].getIntValue();
            if (nargs > 1) {
                nevals_max = args[1].getIntValue();
                nevals_mod = nevals_max;
            }
            if (nargs > 2) {
                nevals_mod = Math.min((nevals_max + 1), args[2].getIntValue());
                nevals_mod = Math.max(nevals_mod, 1);
            }
            if (nargs > 3) {
                nevals_tolfactor = Math.max(1.0, args[3].getDoubleValue());
            }
        }
    }

    public static class SimplexSetDefaults extends DefaultCommand {
        // This primitive resets the simplex parameters restart, nevals_max, 
        // nevals_mod, and nevals_modfactor to their default values.

        @Override
        public Syntax getSyntax() {
            return Syntax.commandSyntax();
        }

        @Override
        public void perform(Argument args[], Context context)
                throws ExtensionException, LogoException {
            nrestarts_max = NRESTARTS_MAX_DEFAULT;
            nevals_max = NEVALS_MAX_DEFAULT;
            nevals_mod = NEVALS_MOD_DEFAULT;
            nevals_tolfactor = NEVALS_TOLFACTOR_DEFAULT;
        }
    }

    public static class SimplexSolveUnconstrained extends DefaultReporter {
        // This primitive sets up the call to PerformSimplex for an 
        // unconstrained minimization.

        @Override
        public Syntax getSyntax() {
            return Syntax.reporterSyntax(new int[]{Syntax.ListType(),
                        Syntax.WildcardType(), Syntax.NumberType(),
                        Syntax.NumberType()},
                    Syntax.NumberType());
        }

        @Override
        public Object report(Argument args[], Context context)
                throws ExtensionException, LogoException {

            // Get the initial guess and turn it from a LogoList to a vector.
            LogoList xlist = args[0].getList();
            int nvar = xlist.size();
            double[] x = new double[nvar];
            for (int j = 0; j < nvar; j++) {
                x[j] = ((Number) xlist.get(j)).doubleValue();
            }

            // Save the remainder of the arguments.
            ReporterTask fnctn = args[1].getReporterTask();
            double tol = args[2].getDoubleValue();
            double delta = args[3].getDoubleValue();

            // Perform the simplex. Loop through the specified number of 
            // restarts, keeping track of the best solution and returning 
            // that solution at the end.

            double bestResult = Double.MAX_VALUE;
            double[] bestSolution = new double[nvar];
            for (int i = 0; i <= nrestarts_max; i++) {
                x = PerformSimplex(x, fnctn, context, tol, delta, false);
                double thisResult = NumAnalExtension.GetFofXvec(x, fnctn, 
                        context);
                if (thisResult < bestResult) {
                    bestResult = thisResult;
                    bestSolution = x.clone();
                }
            }
            return NumAnalExtension.ArrayToSimpleLogoList(bestSolution);
        }
    }

    public static class SimplexSolveConstrained extends DefaultReporter {
        // This primitive sets up the call to PerformSimplex for an 
        // constrained minimization. The solution vector is constrained to 
        // have all non-negative elements.

        @Override
        public Syntax getSyntax() {
            return Syntax.reporterSyntax(new int[]{Syntax.ListType(),
                        Syntax.WildcardType(), Syntax.NumberType(),
                        Syntax.NumberType()},
                    Syntax.NumberType());
        }

        @Override
        public Object report(Argument args[], Context context)
                throws ExtensionException, LogoException {

            // Get the initial guess and turn it from a LogoList to a vector.
            LogoList xlist = args[0].getList();
            int nvar = xlist.size();
            double[] x = new double[nvar];
            for (int j = 0; j < nvar; j++) {
                x[j] = ((Number) xlist.get(j)).doubleValue();
                if (x[j] < 0.0) {
                    throw new ExtensionException(
                            "non-negative-simplex error: Negative element in "
                            + "the initial guess.");
                }
            }

            // Save the remainder of the arguments.
            ReporterTask fnctn = (ReporterTask) args[1].get();
            double tol = args[2].getDoubleValue();
            double delta = args[3].getDoubleValue();

            // Perform the simplex. Loop through the specified number of 
            // restarts, keeping track of the best solution and returning 
            // that solution at the end.

            double bestResult = Double.MAX_VALUE;
            double[] bestSolution = new double[nvar];
            for (int i = 0; i <= nrestarts_max; i++) {
                x = PerformSimplex(x, fnctn, context, tol, delta, true);
                double thisResult = NumAnalExtension.GetFofXvec(x, fnctn, 
                        context);
                if (thisResult < bestResult) {
                    bestResult = thisResult;
                    bestSolution = x.clone();
                }
            }
            return NumAnalExtension.ArrayToSimpleLogoList(bestSolution);
        }
    }

    private static double[] PerformSimplex(double[] x, ReporterTask fnctn,
            Context context, double tol, double delta, boolean constrained)
            throws ExtensionException, LogoException {
        // This is the guts of the simplex algorithm.  It minimizes the 
        // function, fntn, to a tolerance, tol.  x is the initial guess of
        // a solution and delta is the amount by which each dimension of 
        // the initial guess is perturbed to form the initial simplex.

        int nvar = x.length;
        int nevals = 0;
        int nevalsPrior = 0;

        // Now construct the simplex matrix. Set each row to the intial vertex
        // and then perturb a different element of the second through last
        // rows by delta times a random factor in the range 1.0 plus or minus
        // PRANGE_DEFAULT/2, giving us nvar + 1 different vertices.
        // As noted above, we have taken out the random element.
        int nvert = nvar + 1;
        double[][] s = new double[nvert][nvar];
        s[0] = (double[]) x.clone();
        for (int i = 1; i < nvert; i++) {
            s[i] = (double[]) x.clone();
//            s[i][i - 1] += ((1.0 - PRANGE_DEFAULT/2.0) + 
//                    randgen.nextDouble()*PRANGE_DEFAULT) * delta;
            s[i][i - 1] += delta;
        }

        // y is a vector of results.  Fill it with the values of the
        // objective function for each vertex.
        double y[] = new double[nvert];
        for (int i = 0; i < nvert; i++) {
            y[i] = NumAnalExtension.GetFofXvec(s[i], fnctn, context);
        }
        nevals += nvert;

        // sums is a vector of column sums of s.
        double sums[] = new double[nvar];
        sums = GetColumnSums(s);

        // Now we enter into the solution loop.  Note that we break out of
        // the loop manually when a solution is found or when the maximum
        // number of function evaluations has been reached or exceeded.
        while (true) {
            // Find the vertices with the worst (highest), next worst
            // (next highest) and best (lowest) values of the function.
            int iwrst = 0;
            int i2wst = 1;
            if (y[1] > y[0]) {
                iwrst = 1;
                i2wst = 0;
            }
            int ibest = 0;
            for (int i = 0; i < nvert; i++) {
                if (y[i] <= y[ibest]) {
                    ibest = i;
                }
                if (y[i] > y[iwrst]) {
                    i2wst = iwrst;
                    iwrst = i;
                } else if (y[i] > y[i2wst] && i != iwrst) {
                    i2wst = i;
                }
            }

            /*
             * Now check to see if we have achieved the desired tolerance.
             * There is a choice here: we could use a relative tolerance,
             * such as 
             *   2.0 * abs (y[ibest] - y[iwrst]) / (abs y[ibest] + abs y[iwrst])
             * or an absolute tolerance, such as
             *   abs (y[ibest] - y[iwrst])
             * The first is sensitive to the absolute value of the solution 
             * value. If the solution value is close to zero, the denominator 
             * will be very small, and even a very small difference
             * between the best and worst values of y will result in a large 
             * tolerance. So instead, for now at least, we will use the absolute
             * difference.
             * Other possibilities include comparing the change in the best
             * value from one iteration to the next or looking at the size of
             * the simplex itself and stopping with it gets very small.
             */

            if (Math.abs(y[iwrst] - y[ibest]) < tol) {
                return s[ibest];
            }

            // Check for an "infinite" loop.
            if (nevals > nevals_max) {
                throw new ExtensionException(
                        "Simplex error: Exceeded function evaluation limit of "
                        + nevals_max + " interations.");
            }

            // Check to see if the tolerance should be increased.
            if ((nevals/nevals_mod) > (nevalsPrior/nevals_mod)) {
                tol = tol * nevals_tolfactor;
                // and report this to the command center.
                NumAnalExtension.WriteToNetLogo("At step " + nevals
                        + " tol was increased by a factor of "
                        + nevals_tolfactor + " to " + tol, false, context);
            }
            nevalsPrior = nevals;

            // Time to actually begin the next iteration.
            // With the factor of -1, TryNewVertex reflects the current worst 
            // vertex through the opposite face of the simplex and, if the 
            // reflected vertex is better than the original, replaces the 
            // original vertex with the reflected one.  
            // However, if TryNewVertex finds that the reflected vertex
            // is not better than the original, the original vertex is not 
            // replaced, but the (even worse) value of the function at 
            // that reflected vertex is returned in order to signal the need 
            // for a contraction of from the original vertex, in the test 
            // below.
            double ynew = TryNewVertex(s, y, sums, fnctn, context, iwrst,
                    -1.0, constrained);
            nevals += 1;

            if (ynew <= y[ibest]) {
                // The reflected vertex is better than the current best vertex.
                // Expand the simplex in the direction of the new vertex to 
                // hopefully achieve an even better point.  Note that iwrst
                // is pointing to the new, reflected vertex, not to the worst
                // vertex in the new simplex.
                ynew = TryNewVertex(s, y, sums, fnctn, context, iwrst,
                        2.0, constrained);
                nevals += 1;

            } else if (ynew >= y[i2wst]) {
                // If ynew is as bad or worse than the 2nd worst point in the
                // simplex, iwrst must still point to the worst vertex. 
                // That vertex may either be the original worst vertex, or 
                // the reflection of it (which apparently is only marginally
                // better).  In either case, contract the simplex from that 
                // vertex to hopefully find a better point.
                double ysave = y[iwrst];
                ynew = TryNewVertex(s, y, sums, fnctn, context, iwrst,
                        0.5, constrained);
                nevals += 1;

                if (ynew >= ysave) {
                    // Well, even with the contraction away from the worst
                    // vertex we did not find a better point. So, contract 
                    // the entire simplex around the best point, moving 
                    // each vertex halfway to the best vertex. (Note that
                    // the if() statement is not strictly necessary as the 
                    // best vertex would not move anyway. But the if() saves 
                    // nvar calculations for a new vertex and one function
                    // evaluation at the expense of nvert logical 
                    // comparisons.)
                    for (int i = 0; i < nvert; i++) {
                        if (i != ibest) {
                            for (int j = 0; j < nvar; j++) {
                                s[i][j] = 0.5 * (s[i][j] + s[ibest][j]);
                            }
                            y[i] = NumAnalExtension.GetFofXvec(s[i], fnctn, 
                                    context);
                        }
                    }
                    nevals += (nvert - 1);
                    // Update sums.
                    sums = GetColumnSums(s);
                }
            }  // End of the if, else if block.
        }  // End of the while loop.
    }  // End of PerformSimplex


    private static double[] GetColumnSums(double[][] matrx) {
        // Returns an array containing the column sums of array, matrx.
        int nrows = matrx.length;
        int ncols = matrx[0].length;
        double[] colsums = new double[ncols];
        for (int j = 0; j < ncols; j++) {
            double sum = 0.0;
            for (int i = 0; i < nrows; i++) {
                sum += matrx[i][j];
            }
            colsums[j] = sum;
        }
        return colsums;
    }

    private static double TryNewVertex(double[][] s, double[] y, double[] sums,
            ReporterTask fnctn, Context context, int iwrst, double factor,
            boolean constrained) throws ExtensionException, LogoException {
        /*
         * If factor is positive and greater than one, the simplex is expanded
         * by pushing out the the vertex iwrst (which may no longer be the
         * worst!). If factor is positive and less than one, the simplex 
         * is contracted by pulling in the vertex iwrst. Finally, if factor 
         * negative, the vertex iwrst is reflected through the opposite 
         * face of the simplex with abs(factor) being the degree of 
         * reflection.
         * The boolean constrained indicates whether or not all the elements
         * of the new vertex are constrained to be greater than or equal to
         * zero.
         */

        int nvar = sums.length;
        double factor1 = (1.0 - factor) / nvar;
        double factor2 = factor1 - factor;
        double ptry[] = new double[nvar];
        // First, find the new expanded, contracted or reflected vertex.
        if (constrained) {
            for (int j = 0; j < nvar; j++) {
                ptry[j] = Math.max(0.0,
                        (sums[j] * factor1 - s[iwrst][j] * factor2));
            }
        } else {
            for (int j = 0; j < nvar; j++) {
                ptry[j] = sums[j] * factor1 - s[iwrst][j] * factor2;
            }
        }

        double ynew = NumAnalExtension.GetFofXvec(ptry, fnctn, context);
        // If the new vertex is better than the original one, replace the 
        // original one with the new one, updating column sums as well. If 
        // it is not better, the original vertex is not replaced.
        if (ynew < y[iwrst]) {
            y[iwrst] = ynew;
            for (int j = 0; j < nvar; j++) {
                sums[j] += ptry[j] - s[iwrst][j];
                s[iwrst][j] = ptry[j];
            }
        }

        // Return the value at the new vertex, whether or not it has 
        // replaced the original one.
        return ynew;
    }
    
}