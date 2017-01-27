
##############
## Randomized controlled Trials to construct a null model
## for benchmark of algo results
##############


# source stats.R --> l24


# run the algo on ≠ initial ref sets ; by randomly combining provided sets.
# Compare convergence and final lexical consistence / distances ?

# Q : 
#   - R RIS reader ?
#   - not too much dirty to begin to handle refs here ?

# Experiment Design : 
#   K initial corpuses C_i^0
#   from ALL refs, build K random initial corpuses
#     , to compute : E[lexical dist matrix] as baseline for real lexical dist matrix
#                    E[<lexical consistence>_corpuses] " for real <lexical consistence>_corpuses
#                    E[<convergence speed>_corpuses]
#
#  if \sum_i|C_i^0| = N = m*K, number of possible partitions with equal number of elements is
#     \sum_{k=0}^{K-1}{C_k^{N - k * m}}
#
#  for a non-uniform number of elements, we must enumerate multi indexes
#    M = {(k_0,...,k_i) such that k_j > m_{min} and \sum{k_j} = N}
#    then # = \sum_{(k_0,...,k_i)\in M}{\sum{C_{k_j}^N}}
#
#  (-> knitr that ?)
#
#  Q : see distribution for all partitions ? -> if one give more lexically consistent corpuses,
#      consider it ? [beware : normalized lexical consistence, but is it comparable if size differs too much ?]
#      [should run only on equal size for now, and also real of equal sizes ?]
#







