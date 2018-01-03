package org.nlogo.extensions.numanal;

/*
 * This extension provides a number of primitives for finding roots, minima,
 * etc.  Several were adapted from Numerical Recipes in C: The Art of 
 * Scientific Computing, 2nd ed., 1992, by William Press, Saul A. Teukolsky, 
 * William T. Vetterling and Brian Flannery. Other sources were also consulted
 * and there were extensive modifications in the translation to Java and
 * to the NetLogo environment. So, all the errors are indeed mine.
 */

import org.nlogo.api.LogoException;
import org.nlogo.api.ExtensionException;
import org.nlogo.api.Argument;
import org.nlogo.api.Syntax;
import org.nlogo.api.Context;
import org.nlogo.api.DefaultReporter;
import org.nlogo.api.DefaultCommand;
import org.nlogo.nvm.ExtensionContext;
import org.nlogo.api.ReporterTask;
import org.nlogo.api.LogoListBuilder;
import org.nlogo.api.LogoList;
import org.nlogo.nvm.Workspace.OutputDestination;

import Jama.Matrix;


    public class NumAnalExtension extends org.nlogo.api.DefaultClassManager {
    
    // Define the primitives.
    @Override
    public void load(org.nlogo.api.PrimitiveManager primManager) {
        primManager.addPrimitive("simplex-set",
                new Simplex.SimplexSetParams());
        primManager.addPrimitive("simplex-reset",
                new Simplex.SimplexSetDefaults());
        primManager.addPrimitive("simplex",
                new Simplex.SimplexSolveUnconstrained());
        primManager.addPrimitive("simplex-nonneg",
                new Simplex.SimplexSolveConstrained());
        primManager.addPrimitive("Brent-minimize", 
                new BrentMinimize());
        primManager.addPrimitive("Broyden-set",
                new Broyden.BroydenSetParams());
        primManager.addPrimitive("Broyden-reset",
                new Broyden.BroydenSetDefaults());
        primManager.addPrimitive("Broyden-root",
                new Broyden.BroydenFindRoot());
        primManager.addPrimitive("Broyden-failed?",
                new Broyden.BroydenFailed());
        primManager.addPrimitive("Newton-set",
                new Newton.NewtonSetParams());
        primManager.addPrimitive("Newton-reset",
                new Newton.NewtonSetDefaults());
        primManager.addPrimitive("Newton-root",
                new Newton.NewtonFindRoot());
        primManager.addPrimitive("Newton-failed?",
                new Newton.NewtonFailed());
        primManager.addPrimitive("Brent-root", 
                new BrentRoot());
        primManager.addPrimitive("Romberg-integrate", 
                new Romberg.RombergFindIntegral());
    }
    
    public static double[] SimpleLogoListToArray(LogoList xlist) {
        // Converts a simple array to a simple LogoList.
        int n = xlist.size();
        double x[] = new double[n];
        for (int j = 0; j < n; j++) {
            x[j] = ((Number) xlist.get(j)).doubleValue();
        }
        return x;
    }

    public static LogoList ArrayToSimpleLogoList(double[] x) {
        // Converts a simple array to a simple LogoList.
        LogoListBuilder xlist = new LogoListBuilder();
        for (int j = 0; j < x.length; j++) {
            xlist.add(Double.valueOf(x[j]));
        }
        return xlist.toLogoList();
    }
    
    public static double GetFofX(double x, ReporterTask fnctn,
            Context context) {
        // Calls the NetLogo reporter indicated by the task variable fntcn.
        // The reported should take a single x value and return a single
        // y evaluated at x.

        Object[] Array = {x};
        return (Double) fnctn.report(context, Array);
    }
    
    public static double GetFofXvec(double[] x, ReporterTask fnctn,
            Context context) {
        // Calls the NetLogo reporter indicated by the task variable fntcn.
        // The reporter should take a list of x values and
        // return a single y evaluated at x.
        LogoList xlist = ArrayToSimpleLogoList(x);
        Object[] Array = {xlist};
        return (Double) fnctn.report(context, Array);
    }

    /*
    public static double GetFiOfXvec(double[] x,
            ReporterTask fnctn, int i, Context context) {
        // Calls the NetLogo reporter indicated by the task variable fntcn.
        // The reporter should take a list of x values and an index i, and
        // return the result of the ith equation evaluated at x.

        LogoList xlist = ArrayToSimpleLogoList(x);
        Object[] Array = {xlist, (double) i};
        return (Double) fnctn.report(context, Array);
    }


    public static double[] GetFvecOfXvec(double[] x,
            ReporterTask fnctn, Context context) {
        // Calls for each value of i, 0 ... n, the NetLogo reporter 
        // indicated by the task variable fntcn, and returns a 
        // one-dimensional array of the function values evaluated at point x.
        
        int n = x.length;
        LogoList xlist = ArrayToSimpleLogoList(x);
        Object[] Array = {xlist};
        LogoList rslts = (LogoList) fnctn.report(context, Array);
        return SimpleLogoListToArray(rslts);
    }

     */
    
    public static Matrix GetFofX(Matrix X,
            ReporterTask fnctn, Context context) {
        // Converts the 1xn Matrix X to a LogoList and passes it to the NetLogo 
        // reporter indicated by the task variable fntcn.  The reporter
        // returns a list of the function values evaluated at point x.  
        // That list is then converted to a 1xn Matrix and returned.
        
        double[] x = X.getRowPackedCopy();
        LogoList xlist = NumAnalExtension.ArrayToSimpleLogoList(x);
        Object[] Array = {xlist};
        LogoList rslts = (LogoList) fnctn.report(context, Array);
        double[] r = NumAnalExtension.SimpleLogoListToArray(rslts);
        return new Matrix(r, 1);
    }
    
    public static void WriteToNetLogo(String mssg, Boolean toOutputArea, 
            Context context) throws ExtensionException, LogoException {
        /*
         * Instructions on writing to the command center as related by
         * Seth Tissue:
         * "Take your api.ExtensionContext, cast it to nvm.ExtensionContext,
         * and then call the workspace() method to get a nvm.Workspace 
         * object, which has an outputObject() method declared as follows:
         *    void outputObject(Object object, Object owner,
         *    boolean addNewline, boolean readable,
         *    OutputDestination destination)
         *    throws LogoException;
         * 
         * object: can be any valid NetLogo value;
         * owner: just pass null;
         * addNewline: whether to add a newline character afterwards;
         * readable: "false" like print or "true" like write, controls whether
         *   the output is suitable for use with file-read and read-from-string
         *   (so e.g. whether strings are printed with double quotes);
         * OutputDestination is an enum defined inside nvm.Workspace with 
         *   three possible values: NORMAL, OUTPUT_AREA, FILE. NORMAL means 
         *   to the command center, OUTPUT_AREA means to the output area if 
         *   there is one otherwise to the command center, FILE is not 
         *   relevant here.
         */
        
        ExtensionContext extcontext = (ExtensionContext) context;
        try {
            extcontext.workspace().outputObject(mssg, null, true, true,
                    (toOutputArea) ? OutputDestination.OUTPUT_AREA : 
                    OutputDestination.NORMAL);
        } catch (LogoException e) {
            throw new ExtensionException(e);
        }
    }

    public static void MatPrint(String lbl, Matrix M, Context context)
            throws ExtensionException, LogoException {
        int m = M.getRowDimension();
        int n = M.getColumnDimension();
        NumAnalExtension.WriteToNetLogo(lbl + " " + m + " " + n,
                false, context);

        for (int i = 0; i < m; i++) {
            String s = "";
            for (int j = 0; j < n; j++) {
                s = s + M.get(i, j) + " ";
            }
            NumAnalExtension.WriteToNetLogo(s, false, context);
        }
    }

    public static void ValPrint(String lbl, double val, Context context)
            throws ExtensionException, LogoException {
        NumAnalExtension.WriteToNetLogo(lbl + " " + val, false, context);
    }
    
}
