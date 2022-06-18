import manu, algorithm

# Given data
let
   sigma = matrix(@[
      @[180.0, -20, 0],
      @[-20.0, 100, 0],
      @[0.0, 0, -30]
   ])

   sy = 235.0

# Answers first question
var eigvals = eig(sigma).getRealEigenvalues()
eigvals.sort(Descending)

proc tresca(s: seq[float]): float =
   s[0] - s[2] - sy

let res = tresca(eigvals)
if res > 0.0:
   echo "outside surface"
elif res < 0.0:
   echo "inside surface"
else:
   echo "on surface"

# Answers second question
var n = matrix(@[1.0, 1, 0], 3)
let d = normF(n)
n /= d
echo n
