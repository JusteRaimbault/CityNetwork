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

public class NAMatrix {
    
    public static Matrix OuterProduct(Matrix U, Matrix V) {
        // Forms a matrix from the outer product of vectors (defined as 1xn
        // Matrices) U and V.
        return (U.transpose()).times(V);
    }
    
    public static double MaxAbsElement(Matrix M) {
        // Return the element of M with the largest absolute value.
        double[] a = M.getRowPackedCopy();
        double maxElement = 0.0;
        for (int i = 0; i < a.length; i++) {
            maxElement = Math.max(maxElement, Math.abs(a[i]));
        }
        return maxElement;
    }
    
    public static Matrix AbsMatrix(Matrix M) {
        // Return a matrix whose elements are the absolute values of 
        // the elements of M.
        int nrows = M.getRowDimension();
        double[] a = M.getColumnPackedCopy();
        for (int i = 0; i < a.length; i++) {
            a[i] = Math.abs(a[i]);
        }
        return new Matrix(a, nrows);        
    }
    
        
}