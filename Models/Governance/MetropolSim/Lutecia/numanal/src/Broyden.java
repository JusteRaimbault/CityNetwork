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

import Jama.Matrix;

public class Broyden {

    /* These procedures implement the Broyden algorithm for finding the root
     * (the "zero") of a set of n nonlinear equations in n variables. The 
     * central method is BroydenFindRoot.  It takes an initial guess for 
     * the n-dimentsional vector of inputs, x, passed as a NetLogo list, 
     * and a NetLogo ReporterTask, fnctn, referencing the set of equations 
     * for which the root is to be found, and returns the vector x (again,
     * as a NetLogo list) which yields the root.
     * 
     * Specifically, the NetLogo reporter, fnctn, should take a list of x 
     * values and should then return a list of the value of each equation
     * evaluated at x.
     * 
     * The following parameters determine the accuracy with which the Broyden
     * procedure finds the root. We are looking for the rood of the series of
     * eqations (functions), and so one way of knowing when we've found it is
     * to look at the devation from zero of each the function values.  In 
     * particular, if F is the vector of results for any given input vector, x,
     * we look at f = 0.5*F*F, that is half of the sum of squared values of 
     * the function results. If this is small enough, i.e., less than tolf, 
     * we've found the root.
     * 
     * On the other hand, it is possible that we instead find a local or 
     * global minimum of f before we find the root.  In that case, the 
     * change in x that is required to get f to fall will get smaller and 
     * smaller as we approach that minimum.  The Broyden procedure also 
     * checks for that by seeing if the maximum proportionate change in 
     * the elements of x falls below tolx, or if the largest gradient in 
     * any of the x directions falls below tolmin.  Of course, it is possible
     * that the minimum is actually at the root, so the calling program
     * may want to check on that.
     * 
     * Default values for tolf, tolx and tolmin are given below, but they
     * may be changed by the call to BroydenSetParams. Experimentation 
     * suggests that tolx and tolmin be a couple of magnitudes smaller 
     * than tolf.
     * 
     * Other globals are:
     * 
     * max_its: the maximum number of iterations (steps) allowed.
     * PRECISION: the square root of the machine precision for doubles.
     * stpmx: a parameter in the calculation of the maximum  step size
     *   in LineSearch.
     * epsilon: the proportional change in each x element that is used to 
     *   calculate the Jacobian (with a minimum change of epsilon itself).
     * alpha: a parameter that ensures that the LineSearch routine has
     *   been able to find a new x vector that reduces f by a suffient 
     *   amount.
     * 
     * All these globals but PRECISION may also be changed by BroydenSetParams.
     * 
     * There are two additional routines. BroydenSetParams allows the user
     * to change the parameters noted above.  It takes as a minimum two 
     * arguments, tolf and tolx, but may in addition take max_its, tolmin, 
     * epsilon and alpha, in that order, if they are included in the argument
     * list of the reporter.  BroydenReset resets all the parameters to their
     * default values.
     * 
     * This procedure is modeled on Numerical Recipes in C, but with a number 
     * of significan changes.  In terms of form, the algorithm has been 
     * recast to use matrix arithmetic.  This considerably simplifies the 
     * programming and makes the code much more transparent.  There is 
     * presumably a cost to this in terms of computational efficiency, but
     * it is likely to be very small.  We use the Jama Matrix class for
     * manipulating the matrices.  In terms of method, we do not use the 
     * QR decomposition of the Jacobian, rather we use the Jacobian itself
     * to solve for deltaX using the standard Jama Matrix.solve method.  This 
     * is likely a bit slower than using QR decomposition, but it makes for
     * much more transparent code since the Broyden update can be taken 
     * straight from any matrix description of the Broyden algorithm.
     */
    
    static final int MAX_ITS_DEFAULT = 1000;
    static final double PRECISION = Math.sqrt(Double.MIN_NORMAL);
    static final double TOLF_DEFAULT = 1.0e-6;
    static final double TOLX_DEFAULT = 1.0e-8;
    static final double STPMX_DEFAULT = 100.0;
    static final double TOLMIN_DEFAULT = 1.0e-8;
    static final double EPSILON_DEFAULT = 1.0e-4;
    static final double ALPHA_DEFAULT = 1.0e-6;

    static int max_its = MAX_ITS_DEFAULT;
    static double tolf = TOLF_DEFAULT;
    static double tolx = TOLX_DEFAULT;
    static double stpmx = STPMX_DEFAULT;
    static double tolmin = TOLMIN_DEFAULT;
    static double epsilon = EPSILON_DEFAULT;
    static double alpha = ALPHA_DEFAULT;

    static boolean failedToFindRoot = false;
    static boolean linesearchFailed;

    public static class BroydenSetParams extends DefaultCommand {

        @Override
        public Syntax getSyntax() {
            return Syntax.commandSyntax(new int[]
            {Syntax.NumberType() | Syntax.RepeatableType()});
        }

        @Override
        public void perform(Argument args[], Context context)
                throws ExtensionException, LogoException {
            int nargs = args.length;
            tolf = args[0].getDoubleValue();
            if (nargs > 1) {
                tolx = args[1].getDoubleValue();
            }
            if (nargs > 2) {
                tolmin = args[2].getDoubleValue();
            }
            if (nargs > 3) {
                max_its = args[3].getIntValue();
            }
            if (nargs > 4) {
                epsilon = args[4].getDoubleValue();
            }
            if (nargs > 5) {
                alpha = args[5].getDoubleValue();
            }
        }
    }

    public static class BroydenSetDefaults extends DefaultCommand {

        @Override
        public Syntax getSyntax() {
            return Syntax.commandSyntax(new int[]{});
        }

        @Override
        public void perform(Argument args[], Context context)
                throws ExtensionException, LogoException {
             tolf = TOLF_DEFAULT;
             tolx = TOLX_DEFAULT;
             max_its = MAX_ITS_DEFAULT;
             tolmin = TOLMIN_DEFAULT;
             epsilon = EPSILON_DEFAULT;
             alpha = ALPHA_DEFAULT;
        }
    }
    
    public static class BroydenFailed extends DefaultReporter {

        @Override
        public Syntax getSyntax() {
            return Syntax.reporterSyntax(new int[] {}, Syntax.BooleanType());
        }

        @Override
        public Object report(Argument args[], Context context)
                throws ExtensionException, LogoException {
            return failedToFindRoot;
        }
    }

    public static class BroydenFindRoot extends DefaultReporter {

        @Override
        public Syntax getSyntax() {
            return Syntax.reporterSyntax(new int[]{Syntax.ListType(),
                        Syntax.WildcardType()},
                    Syntax.ListType());
        }

        @Override
        public Object report(Argument args[], Context context)
                throws ExtensionException, LogoException {

            // get the initial guess and put it in a 1xn Matrix, X
            LogoList xlist = args[0].getList();
            int n = xlist.size();
            double[] x = NumAnalExtension.SimpleLogoListToArray(xlist);
            Matrix X = new Matrix(x, 1);

            // Save the remainder of the arguments.
            ReporterTask fnctn = args[1].getReporterTask();

            // Evaluate all the functions at the initial guess and put the
            // results in a 1xn matrix, F.
            // ftest is then 0.5 * F*F'.
            Matrix F = NumAnalExtension.GetFofX(X, fnctn, context);
            double ftest = 0.5 * (F.times(F.transpose())).get(0, 0);

            // Test to see if the guess is a root, using a tougher test
            // than TOLF.  The test is based on the maximum deviation of any 
            // f(x) from zero.
            if (NAMatrix.MaxAbsElement(F) < 0.01 * tolf) {
                failedToFindRoot = false;
                return NumAnalExtension.ArrayToSimpleLogoList(x);
            }

            // Calculate the maximum step for line searches.
            double sum = (X.times(X.transpose())).get(0, 0);
            double stpmax = stpmx * Math.max(Math.sqrt(sum), (double) n);


            // The compiler doesn't like it if these are not itialized.
            Matrix J = new Matrix(n, n);
            Matrix X_old = new Matrix(1, n);
            Matrix F_old = new Matrix(1, n);

            boolean restart = true;

            for (int its = 0; its < max_its; its++) {
                if (restart) {
                    // Initialize or reintitialize the Jacobian matrix, J.
                    // Then do a QR decomposition of it and extract the parts.  
                    J = Jacobian(X, F, fnctn, context);
                } else {
                    // Carry out a Broyden update, calculating the updated
                    // Jacobian in steps.
                    // Note, we never get here on the first step, so X_old &
                    // F_old will have been set on the previous step.
                    // deltaX, deltaF are 1xn.  J is nxn.  So temp is nx1.
                    // So temp*deltaX is an nxn outerproduct.
                    Matrix dX = X.minus(X_old);
                    Matrix dF = F.minus(F_old);
                    Matrix temp =
                            dF.transpose().minus(J.times(dX.transpose()));
                    // Here we need to make sure that at least one element of
                    // temp has the required magnitude as we don't want to 
                    // update with "noisy" elements. Elements that are too
                    // small are set to zero.  Note that if all are zero, we
                    // skip the update of J and go into the next line search
                    // with the old J, but a new value of X.
                    //
                    // First create tmp as the matrix sum of the absolute 
                    // values of F and F_old, then 
                    // multiply each resulting element by the machine 
                    // precision. Finally, if any element of temp is less than
                    // the corresponding element of tmp, set that element of
                    // temp to zero.
                    Matrix tmp = 
                        (NAMatrix.AbsMatrix(F)).plus(NAMatrix.AbsMatrix(F_old));
                    tmp = tmp.timesEquals(PRECISION);
                    for (int i = 0; i < n; i++) {
                        if (temp.get(i, 0) < tmp.get(0,i)) {
                            temp.set(i, 0, 0.0);
                        }
                    }
                    if (NAMatrix.MaxAbsElement(temp) > 0.0) {
                        // At least one element of temp is big enough. 
                        // Continue with the update of J.
                        double dFsquared =
                                dF.times(dF.transpose()).get(0, 0);
                        temp = temp.timesEquals(1.0 / dFsquared);
                        J = J.plusEquals(temp.times(dX));
                    }
                }

                // Compute nablaF = F*J = (Q*R)transpose * F = F*(Q*R), 
                // for the line search.
                Matrix nablaF = F.times(J);

                // Save old values of X and ftest.
                X_old = X.copy();
                F_old = F.copy();
                double ftest_old = ftest;

                // Solve J*deltaX' = -F' for deltaX.  Remember that J = Q*R 
                // (or at least approximately so after a Broyden update).
                Matrix deltaX = 
                        (J.solve(F.times(-1.0).transpose())).transpose();


                // Now set up the LineSearch and, upon return, recalculate
                // F and ftest at the new point (unless the search failed!).
                // NOTE: LineSearch actually returns three values.  See the 
                // comments associated with the LineSearch, below.
                X = LineSearch(X_old, ftest_old, nablaF,
                        deltaX, X, stpmax, fnctn, context);
                if (!linesearchFailed) {
                    F = NumAnalExtension.GetFofX(X, fnctn, context);
                    ftest = 0.5 * (F.times(F.transpose())).get(0, 0);
                }

                // Check for convergence and, if found, return the point.
                if (NAMatrix.MaxAbsElement(F) < tolf) {
                    failedToFindRoot = false;
                    x = X.getRowPackedCopy();
                    return NumAnalExtension.ArrayToSimpleLogoList(x);
                }

                // We need this matrix in two places below, so form it now.
                // Each element of X1 is the larger of the absolute value of
                // the corresponding element of X or 1.
                Matrix X1 = new Matrix(1, n);
                for (int j = 0; j < n; j++) {
                    X1.set(0, j, Math.max(Math.abs(X.get(0, j)), 1.0));
                }

                if (linesearchFailed) {
                    /* The line search failed to find a new x.
                     * If we have already tried reinitializing the Jacobian,
                     * there is nothing left to do and we return the current
                     * x.  Otherwise check for a gradient of zero signalling
                     * a local minimmum. If we find it, we return the
                     * current x.  In both cases we set failedToFindRoot to
                     * true so the calling program can check it. 
                     * If we have not just calculated the Jocobian and if 
                     * the gradient is not zero, we signal a reinitialization of
                     * the Jacobian on the next step to try again.
                     */
                    if (restart) {
                        failedToFindRoot = true;
                        x = X.getRowPackedCopy();
                        NumAnalExtension.WriteToNetLogo(
                                "LineSearch failed after restart.",
                                false, context);
                        return NumAnalExtension.ArrayToSimpleLogoList(x);
                    } else {
                        // Check for a gradient of zero, i.e., spurious 
                        // convergence.
                        double den = Math.max(ftest, 0.5 * n);
                        double test =
                                NAMatrix.MaxAbsElement(nablaF.arrayTimes(X1));
                        if (test / den < tolmin) {
                            failedToFindRoot = true;
                            x = X.getRowPackedCopy();
                            NumAnalExtension.WriteToNetLogo(
                                    "NewtonFindRoot: spurious convergence",
                                    false, context);
                            return NumAnalExtension.ArrayToSimpleLogoList(x);
                        }
                        restart = true;
                    }

                } else {
                    // LineSearch did find a new x. Get set for using a Broyden
                    // update on the next step, testing first for convergence.
                    double test =
                    NAMatrix.MaxAbsElement(X.minus(X_old).arrayRightDivide(X1));
                    if (test < tolx) {
                        failedToFindRoot = false;
                        x = X.getRowPackedCopy();
                        return NumAnalExtension.ArrayToSimpleLogoList(x);
                    }
                    restart = false;
                }
            }
            // Out of the loop. Throw an error.
            throw new ExtensionException(
                    "Broyden error - maximum number of iterations exceeded.");
        }
    }

    /*********************************************************************/
    
        private static Matrix Jacobian(Matrix X, Matrix F, ReporterTask fnctn, 
            Context context) throws ExtensionException, LogoException {
        // Computes the forward-difference approximation to the Jacobian at
        // point X of the set of functions contained in fnctn. F is a
        // vector of the function values at point X and the Jacobean is
        // returned as a Matrix.  Both X and F are 1xn Matrix objects.

        int n = X.getColumnDimension();
        Matrix J = new Matrix(n, n);
        
        // Compute the Jacobian one column of partials at a time.
        for (int j = 0; j < n; j++) {
            // save the current value of X[j] and replace it with a value
            // a small distance, h, away.  Then compute the partial
            // derivatives and set X[j] back to its original value.
            double temp = X.get(0, j);
            double h = Math.max(epsilon * Math.abs(temp), PRECISION);
            X.set(0, j, temp + h);
//          h = X.get(0, j) - temp;  // Trick to reduce finite precision error.
            Matrix F_new = NumAnalExtension.GetFofX(X, fnctn, context);
            Matrix Partial_j = (F_new.minus(F)).times(1.0/h);
            
            // Partial_j is a 1xn Matrix, that needs to be inserted as the j'th
            // column of the Jacobian.  So, we transpose it to an nx1 Matrix.
            J.setMatrix(0, n-1, j, j, Partial_j.transpose());
            
            X.set(0, j, temp);
        }
        return J;
    }


    private static Matrix LineSearch(Matrix X_old, double ftest_old, 
            Matrix nablaF, Matrix deltaX, Matrix X, double stpmax, 
            ReporterTask fnctn, Context context) 
            throws ExtensionException, LogoException {
        /*
         * Given an n-dimensional point X_old and, at that point, 
         * nablaF and deltaX, find and return a the new point in the 
         * direction given by deltaX where the function has decreased
         * "sufficiently". 
         * stpmax limits the length of the steps so that you do not try to
         * evaluate the function in regions where it is not defined or
         * subject to overflow. If the step succeeds, the global 
         * linesearchFailed is set to true. If the step fails, i.e., if the 
         * new point is too close to the old, linesearchFailed is set to 
         * false. In a minimization this usually signals
         * convergence and can be ignored. In root finding, the calling
         * program should check whether the convergence is spurious.
         * 
         * NOTE: deltaX is also changed in this procedure.  It is not 
         * explicitly returned, but rather modified "in place" using the 
         * .timesEquals() method.  This is a Java no-no, but we use it anyway.
         */

        int n = X.getColumnDimension();

        // Check step size and then compute slope = nablaF * (transpose)deltaX.
        double test = Math.sqrt((deltaX.times(deltaX.transpose())).get(0, 0));        
        if (test > stpmax) {
            // Attempted step is too large. Scale down.
            // NOTE that deltaX is altered "in place", so its new values
            // will be seen in the calling program.
            deltaX = deltaX.timesEquals(stpmax/test);
        }
        double slope = (nablaF.times(deltaX.transpose())).get(0,0);

        // Compute the minimum value for lambda and set the initial value of
        // lambda to one, a full Newton step.
        Matrix X_old1 = new Matrix(1, n);
        for (int j = 0; j < n; j++) {
            X_old1.set(0, j, Math.max(Math.abs(X_old.get(0, j)), 1.0));
        }
        test = NAMatrix.MaxAbsElement(deltaX.arrayRightDivide(X_old1));
        double lambdaMin = tolx / test;
        double lambda = 1.0;
        
        // Don't really need to be initialized as they are not used in the
        // first step, but the compiler likes it.
        double tmplam = 0.0, lambda2 = 0.0, ftest2 = 0.0, ftest_old2 = 0.0;
        while (true) {
            
            if (lambda < lambdaMin) {
                // The change in the x vector required to get f to fall
                // significantly during backtracking has gotten very small.
                // We may have hit a local minimum, either at a zero root
                // or at some othe point. The calling program will need 
                // to check. We use the most recent X.
                linesearchFailed = true;
                return X;
            }
            
            // calculate the new point to be tried and try it.
            X = X_old.plus(deltaX.times(lambda));
            Matrix F = NumAnalExtension.GetFofX(X, fnctn, context);
            double ftest = 0.5 * (F.times(F.transpose())).get(0, 0);
 
            if (ftest <= ftest_old + alpha * lambda * slope) {
                // We've made a significant enough step toward the root
                // as measured by the decrease in ftest. Return the new X.
                linesearchFailed = false;
                return X;
            } else {
                // Backtrack.
                if (lambda == 1.0) {
                    // This is the first backtrack.  Calculate a new trial
                    // lambda value using a quadratic model for g(lambda).
                    tmplam = -slope / (2.0 * (ftest - ftest_old - slope));
                } else {
                    // The first backtrack did not work. Calculate a new
                    // trial lambda using a cubic model for g(lambda).
                    // NOTE, this could be set up as a matrix multiplication.
                    // It might make it more transparent, but not necessarily
                    // faster!
                    double lambda_squared = lambda * lambda;
                    double lambda2_squared = lambda2 * lambda2;
                    double lambdaMlambda2 = lambda - lambda2;
                    double rhs1 = ftest - ftest_old - lambda * slope;
                    double rhs2 = ftest2 - ftest_old2 - lambda2 * slope;
                    double a = ( rhs1 / lambda_squared
                            - rhs2 / lambda2_squared ) / lambdaMlambda2;
                    double b = ( -lambda2 * rhs1 / lambda_squared
                            + lambda * rhs2 / lambda2_squared )
                            / lambdaMlambda2;
                    if (a == 0.0) {
                        // coefficient on the cubic term is zero.
                        tmplam = -slope / (2.0 * b);
                    } else {
                        double disc = b * b - 3.0 * a * slope;
                        if (disc < 0.0) {
                            throw new ExtensionException("Broyden error - "
                                    + "roundoff problem in LineSearch");
                        } else {
                            tmplam = (-b + Math.sqrt(disc)) / (3.0 * a);
                        }
                    }
                    // constrain lambda <= 0.5*lambda1.
                    tmplam = Math.min(0.5 * lambda, tmplam);
                }
            }
            lambda2 = lambda;
            ftest2 = ftest;
            ftest_old2 = ftest_old;
            
            // constrain lambda >= 0.1*lambda1.
            lambda = Math.max(tmplam, 0.1 * lambda);
        }
        // go back and try again.
    }
    
}