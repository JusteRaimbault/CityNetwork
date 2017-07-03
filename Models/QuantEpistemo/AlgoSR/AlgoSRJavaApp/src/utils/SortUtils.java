package utils;

	/*
	 * Copyright 2004, 2005, 2006 Odysseus Software GmbH
	 *
	 * Licensed under the Apache License, Version 2.0 (the "License");
	 * you may not use this file except in compliance with the License.
	 * You may obtain a copy of the License at
	 *
	 *     http://www.apache.org/licenses/LICENSE-2.0
	 *
	 * Unless required by applicable law or agreed to in writing, software
	 * distributed under the License is distributed on an "AS IS" BASIS,
	 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	 * See the License for the specific language governing permissions and
	 * limitations under the License.
	 */ 

	import java.util.Arrays;
	import java.util.Comparator;
	import java.util.Iterator;
	import java.util.List;

	/**
	 * Utility class providing some useful static sort methods. The sort routines
	 * all return index permutations p such that data[p[0]],..,data[p[data.length-1]]
	 * is in sorted order. The data array itself is not modified.
	 * To actually rearrange the array elements, the inverse of p can be used to
	 * permute the array, such that data[0],..,data[data.length-1] is in sorted
	 * order. Use <code>getIterator(p, data)</code> to iterate in sorted order.
	 * A code example may show you what to do next:
	 * <pre>
	 * String[] colors = { "red", "green", "blue" };
	 * int[] p = SortUtils.sort(colors, new StringComparator());
	 * // --> (colors[p[0]], colors[p[1]], colors[p[2]]) == ("blue","green","red")
	 * Iterator iter = SortUtils.getIterator(p, colors)
	 * // --> (iter.next(), iter.next(), iter.next()) == ("blue","green","red")
	 * SortUtils.permute(SortUtils.inverse(p), colors, true);
	 * // --> (colors[0], colors[1], colors[2]) == ("blue","green","red")
	 * </pre>
	 * Stable sorts (preserving order of equal elements) are supported.
	 * Sorting is done using quick-sort mith median of 3 (and insertion-sort
	 * for small ranges).
	 *
	 * @author Christoph Beck
	 */
	public class SortUtils {
	  /**
	   * Helper class used to perform quicksort.
	   *
	   * @author Christoph Beck
	   */
	  static final class QuickSorter {
	    private static final int INSERTIONSORT_THRESHOLD = 7;

	    private final Object[] data;

	    QuickSorter(Object[] data) {
	      this.data = data;
	    }
	    private int compare(Comparator cmp, boolean stable, int i, int j) {
	      int result = cmp.compare(data[i], data[j]);
	      if (result == 0 && stable && i != j) {
	        result = i < j ? -1 : 1;
	      }
	      return result;
	    }
	    private int med3(Comparator cmp, int a, int b, int c) {
	        return  (compare(cmp, false, a, b) < 0 ?
	            (compare(cmp, false, b, c) < 0 ? b : compare(cmp, false, a, c) < 0 ? c : a) :
	            (compare(cmp, false, b, c) > 0 ? b : compare(cmp, false, a, c) < 0 ? c : a));
	    }
	    private int pivot(int[] indices, Comparator cmp, int lo, int hi) {
	      return med3(cmp, indices[lo + 1], indices[(lo + hi) / 2], indices[hi - 1]);
	    }
	    private void swap(int[] indices, int i, int j) {
	      int tmp = indices[i];
	      indices[i] = indices[j];
	      indices[j] = tmp;
	    }
	    private void insertionSort(int[] indices, Comparator cmp, boolean stable, int lo, int hi) {
	      for (int i = lo; i <= hi; i++) {
	            for (int j = i; j > lo && compare(cmp, stable, indices[j-1], indices[j]) > 0; j--) {
	              swap(indices, j-1, j);
	            }
	          }
	    }
	    private void quickSort(int[] indices, Comparator cmp, boolean stable, int lo0, int hi0) {
	      int pivot = pivot(indices, cmp, lo0, hi0);
	      int lo = lo0, hi = hi0;
	      while (lo <= hi) {
	        while (lo < hi0 && compare(cmp, stable, pivot, indices[lo]) > 0)
	          ++lo;
	        while (hi > lo0 && compare(cmp, stable, pivot, indices[hi]) < 0)
	          --hi;
	        if (lo <= hi) {
	          swap(indices, lo++, hi--);
	        }
	      }
	      sort(indices, cmp, stable, lo0, hi);
	      sort(indices, cmp, stable, lo, hi0);
	    }
	    void sort(int[] indices, Comparator cmp, boolean stable, int lo, int hi) {
	      if (hi - lo < INSERTIONSORT_THRESHOLD) {
	        insertionSort(indices, cmp, stable, lo, hi);
	      } else {
	        quickSort(indices, cmp, stable, lo, hi);
	      }
	    }
	    void sort(int[] indices, Comparator cmp, boolean stable) {
	      sort(indices, cmp, stable, 0, indices.length - 1);
	    }
	    int[] sort(Comparator cmp, boolean stable) {
	      int[] indices = identity(data.length);
	      sort(indices, cmp, stable);
	      return indices;
	    }
	  }

	  /**
	   * Create identity permutation, that is <code>{0, 1, ..., n}</code>
	   */
	  public static int[] identity(int n) {
	    int[] indices = new int[n];
	    for (int i = 0; i < n; i++)
	      indices[i] = i;
	    return indices;
	  }

	  /**
	   * Create reverse permutation, that is <code>{n-1, .... 1, 0}</code>
	   */
	  public static int[] reverse(int n) {
	    int[] indices = new int[n];
	    for (int i = 0; i < n; i++)
	      indices[i] = n - i - 1;
	    return indices;
	  }

	  /**
	   * Compute inverse permutation
	   */
	  public static int[] inverse(int[] p) {
	    int[] pi = new int[p.length];
	    for (int i = 0; i < pi.length; i++)
	      pi[p[i]] = i;
	    return pi;
	  }

	  /**
	   * Rearrange the specified data according to the specified permutation.
	   * That is, the array is rearranged, such that
	   * <code>data_after[p[i]] == data_before[i]</code>.
	   * @param data data to be permuted
	   * @param p the permutation
	   * @param clone if true, rearrange a clone instead of the original data;
	   * @return the permuted array (which is the original reference if clone == false)
	   */
	  public static Object[] permute(int[] p, Object[] data, boolean clone) {
	    Object[] permuted = null;

	    if (clone) {
	      permuted = (Object[])data.clone();
	      for (int i = 0; i < data.length; i++)
	        permuted[p[i]] = data[i];
	    } else {
	      // run thru cycles
	      int i = 0;
	      while (i < p.length) {
	        if (p[i] < 0 || p[i] == i) // skip already handled and cycles of length 1
	          ++i;
	        else { // start a new cycle
	          int j = p[i];
	          Object save = data[i];
	          while (p[j] >= 0) {
	            Object tmp = data[j];
	            data[j] = save;
	            save = tmp;
	            i = j;
	            j = p[j];
	            p[i] = -1;
	          }
	        }
	      }
	      permuted = data;
	    }
	    return permuted;
	  }

	  /**
	   * Answer iterator, which iterates over specified data array according
	   * to the specified permutation, that is
	   * <code>data[p[0]],..,data[p[data.length-1]]</code>
	   */
	  public static Iterator getIterator(final int[] p, final Object[] data) {
	    return new Iterator() {
	      int pos = 0;
	      public boolean hasNext() {
	        return pos < data.length;
	      }
	      public Object next() {
	        return data[p[pos++]];
	      }
	      public void remove() {
	        throw new UnsupportedOperationException("Cannot remove from immutable iterator!");
	      }
	    };
	  }

	  /**
	   * Answer iterator, which iterates over specified data list according
	   * to the specified permutation, that is
	   * <code>data.get(p[0]),..,data.get(p[data.length-1])</code>
	   */
	  public static Iterator getIterator(final int[] p, final List data) {
	    return new Iterator() {
	      int pos = 0;
	      public boolean hasNext() {
	        return pos < data.size();
	      }
	      public Object next() {
	        return data.get(p[pos++]);
	      }
	      public void remove() {
	        throw new UnsupportedOperationException("Cannot remove from immutable iterator!");
	      }
	    };
	  }

	//  /**
	//   * An improved heap builder.
	//   * Assumes children of i at 2i and 2i+1 (requires i>0)
	//   */
	//  private static void cheap(int[] indices, Object[] data, Comparator comparator, int i, int j) {
//	    int k = (i << 1);
//	    if (k > j)
//	      return;
//	    while (k < j) {
//	      if (comparator.compare(data[indices[k]], data[indices[k + 1]]) < 0)
//	        k++;
//	      k <<= 1;
//	    }
//	    if (k > j)
//	      k >>= 1;
//	    while (comparator.compare(data[indices[k]], data[indices[i]]) < 0)
//	      k >>= 1;
//	    int t1 = indices[i], t2;
//	    while (k > i) {
//	      t2 = indices[k];
//	      indices[k] = t1;
//	      k >>= 1;
//	      t1 = indices[k];
//	      indices[k] = t2;
//	      k >>= 1;
//	    }
//	    if (k == i)
//	      indices[i] = t1;
	//  }
	//
	//  /**
	//   * Do a (clever) heapsort.
	//   *
	//   * @param comparator Comparator object specifying the sort order.
	//   */
	//  public static void cheapSort(int[] indices, Object[] data, Comparator comparator) {
//	    int n = data.length;
//	    if (n > 1) {
//	      int i;
//	      int m = 0;
//	      for (i = 1; i < n; i++)
//	        if (comparator.compare(data[indices[i]], data[indices[m]]) < 0)
//	          m = i;
//	      if (m > 0) {
//	        int t = indices[0];
//	        indices[0] = indices[m];
//	        indices[m] = t;
//	      }
//	      if (n > 2) {
//	        for (i = n / 2; i > 1; i--)
//	          cheap(indices, data, comparator, i, n - 1);
//	        for (i = n - 1; i > 1; i--) {
//	          cheap(indices, data, comparator, 1, i);
//	          int t = indices[1];
//	          indices[1] = indices[i];
//	          indices[i] = t;
//	        }
//	      }
//	    }
	//  }
	//
	//  /**
	//   * Perform a cheapsort
	//   */
	//  public static int[] cheapSort(Object[] data, Comparator comparator) {
//	    int[] indices = identity(data.length);
//	    cheapSort(indices, data, comparator);
//	    return indices;
	//  }

	  /**
	   * Do a sort on indices.
	   * @param data data to be sorted
	   * @param comparator comparator to use
	   * @param stable do a stable sort iff true
	   * @param indices into data (any permutation of 0,..data.length-1).
	   */
	  public static void sort(int[] indices, Object[] data, Comparator comparator, boolean stable) {
	    new QuickSorter(data).sort(indices, comparator, stable);
	  }

	  /**
	   * Do a sort on indices.
	   * @param data data to be sorted
	   * @param comparator comparator to use
	   * @param stable do a stable sort iff true
	   * @return permutation p such that data[p[0]],..,data[p[data.length-1]] is in sorted order
	   */
	  public static int[] sort(Object[] data, Comparator comparator, boolean stable) {
	    int[] indices = identity(data.length);
	    sort(indices, data, comparator, stable);
	    return indices;
	  }
	  
	  
	  public static int[] sortDesc(double[] d){
		  Comparator dc = new DoubleComparator();
		  Double[] data = new Double[d.length];for(int i=0;i<d.length;i++){data[i]=new Double(d[i]);}
		  return sort(data,dc,false);
	  }
	  

	  /**
	   * Do an unstable sort.
	   * @param data data to be sorted
	   * @param comparator comparator to use
	   * @return permutation p such that data[p[0]],..,data[p[data.length-1]] is in sorted order
	   */
	  public static int[] sort(Object[] data, Comparator comparator) {
	    return sort(data, comparator, false);
	  }

	  /**
	   * Do an unstable sort.
	   * @param data data to be sorted
	   * @param indices into data (permutation of 0,..data.length-1).
	   */
	  public static void sort(int[] indices, Object[] data, Comparator comparator) {
	    sort(indices, data, comparator, false);
	  }

	  /**
	   * Test method
	   */
	  public static void main(String[] args) {
	    Comparator cmp = new Comparator() {
	      public int compare(Object o1, Object o2) {
	        return ((Comparable)o1).compareTo(o2);
	      }
	    };

	    int n = 1000000;
	    if (args.length == 1)
	      try {
	        n = Integer.parseInt(args[0]);
	      } catch (Exception e) {
	        System.err.println(e);
	      }
	    System.out.println("Generating " + n + " random integers...");
	    java.util.Random random = new java.util.Random();
	    Integer[] data = new Integer[n];
	    for (int i = 0; i < n; i++) {
	      data[i] = new Integer(Math.abs(random.nextInt()));
//	      data[i] = new Integer(i);
	    }
	    int[] indices;
	    long time;

	    System.out.print("Arrays.sort...");
	    time = System.currentTimeMillis();
	    Integer[] clone = (Integer[])data.clone();
	    Arrays.sort(clone, cmp);
	    System.out.println(System.currentTimeMillis()-time  + "ms");

	    System.out.print("quicksort...");
	    indices = identity(n);
	    time = System.currentTimeMillis();
	    sort(indices, data, cmp, false);
	    System.out.println(System.currentTimeMillis()-time  + "ms");
	    for (int i = 1; i < n; i++)
	      if (cmp.compare(data[indices[i-1]], data[indices[i]]) > 0)
	        System.err.println("proplem: quickSort at " + i);

	    System.out.print("quicksort stable...");
//	    indices = identity(n);
	    time = System.currentTimeMillis();
	    sort(indices, data, cmp, true);
	    System.out.println(System.currentTimeMillis()-time + "ms");
	    for (int i = 1; i < n; i++) {
	      int res = cmp.compare(data[indices[i-1]], data[indices[i]]);
	      if (res > 0)
	        System.err.println("proplem: quickSort stable at " + i);
	      if (res == 0 && indices[i-1] > indices[i])
	        System.err.println("proplem: quickSort stable (not stable) at " + i);
	    }

//	    System.out.print("cheapsort...");
//	    time = System.currentTimeMillis();
//	    indices = cheapSort(data, cmp);
//	    System.out.println(System.currentTimeMillis()-time + "ms");
//	    for (int i = 1; i < n; i++)
//	      if (cmp.compare(data[indices[i-1]], data[indices[i]]) > 0)
//	        System.err.println("proplem: cheapSort at " + i);
	  
	    System.out.print("permutate copy...");
	    time = System.currentTimeMillis();
	    Object[] data_copy = permute(inverse(indices), data, true);
	    System.out.println(System.currentTimeMillis()-time + "ms");
	    for (int i = 1; i < n; i++)
	      if (cmp.compare(data_copy[i-1], data_copy[i]) > 0)
	        System.err.println("proplem: permute copy at " + i);

	    System.out.print("permutate original...");
	    time = System.currentTimeMillis();
	    permute(inverse(indices), data, false);
	    System.out.println(System.currentTimeMillis()-time + "ms");
	    for (int i = 1; i < n; i++)
	      if (cmp.compare(data[i-1], data[i]) > 0)
	        System.err.println("proplem: permute original at " + i);
	  }
	}
