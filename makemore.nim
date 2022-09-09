import std/sequtils, std/strutils, std/tables, std/sets, std/algorithm, pixie,
    arraymancer, std/sugar, random

let words = readFile("names.txt").split("\n")

var N = zeros[int32]([28, 28])

let chars = words.join("").toHashSet().toSeq().sorted()

var stoi: Table[string, int]
stoi["."] = 0
for i, c in chars:
  stoi[$c] = i + 1

var itos: Table[int, string]
for s, i in stoi:
  itos[i] = s

echo itos

for w in words:
  var chs = @["."] & toSeq(w.mapIt($it)) & @["."]
  for i, (ch1, ch2) in zip(chs, chs[1..^1]):
    let
      ix1 = stoi[ch1]
      ix2 = stoi[ch2]
    N[ix1, ix2] += 1

# heat map

# var figure = newImage(60*27, 60*27)
# let ctx = newContext(figure)
# ctx.font = "Roboto-Regular_1.ttf"
# ctx.fontSize = 18

# let maxCount = max(N)
# echo maxCount

# let
#   lowColor = "#FFFFFF".parseHtmlHex()
#   highColor = "#2980b9".parseHtmlHex()

# for x in 0 ..< 27:
#   for y in 0 ..< 27:

#     ctx.fillStyle = mix(lowColor, highColor, sqrt(N[y, x].float32 / maxCount.float32))
#     ctx.fillRect(x.float32*60, y.float32*60, 60, 60)

#     ctx.fillStyle = "#2c3e50"

#     ctx.fillText(
#       itos[y] & itos[x],
#       x.float32*60 + 30 - ctx.measureText(itos[y] & itos[x]).width / 2,
#       y.float32*60 + 25
#     )
#     ctx.fillText(
#       $N[y, x],
#       x.float32*60 + 30 - ctx.measureText($N[y, x]).width / 2,
#       y.float32*60 + 45
#     )

# figure.writeFile("figure.png")

echo N[0, _]

echo N.rank
echo N.shape
# PyTrouch gives you a reshaped tensor, but here we need to do it then
# map can be used to convert it to float32
var p = N[0, _].reshape([28]).map(x => x.float) / sum(N[0, _]).float

# var p = randomTensor([3], 1f)
# p = p / p.sum()
# echo p


proc searchsorted[T](x: openarray[T], value: T, leftSide: static bool = true): int =
  ## Returns the index corresponding to where the input value would be inserted at.
  ## Input must be a sorted 1D seq/array.
  ## In case of exact match, leftSide indicates if we put the value
  ## on the left or the right of the exact match.
  ##
  ## This is equivalent to Numpy and Tensorflow searchsorted
  ## Example
  ##    [0, 3, 9, 9, 10] with value 4 will return 2
  ##    [1, 2, 3, 4, 5]             2 will return 1 if left side, 2 otherwise
  #
  # Note: this will have a proper and faster implementation for tensors in the future

  when leftSide:
    result = x.lowerBound(value)
  else:
    result = x.upperBound(value)

proc sample[T](probs: Tensor[T]): int =
  ## Returns a weighted random sample (multinomial sampling)
  ## from a 1D Tensor of probabilities.
  ## Probabilities must sum to 1 (normalised)
  ## For example:
  ##    - a Tensor of [0.1, 0.4, 0.2, 0.3]
  ##      will return 0 in 10% of cases
  ##                  1 in 40% of cases
  ##                  2 in 20% of cases
  ##                  3 in 30% of cases
  assert probs.rank == 1
  assert probs.is_C_contiguous
  assert probs.sum - 1.T < T(1e-5)

  # Get a sample from an uniform distribution
  let u = T(rand(1.0))

  # Get the Cumulative Distribution Function of our probabilities
  let cdf = cumsum(probs, axis = 0)

  # We pass our 1D Tensor as an openarray to `searchsorted` avoid copies
  let cdfA = cast[ptr UncheckedArray[T]](cdf.unsafe_raw_offset)
  result = cdfA.toOpenArray(0, cdf.size - 1).searchsorted(u, leftSide = false)

#echo p.sample()

proc multinomial[T](probs: Tensor[T], numSamples: int): Tensor[int] =
  var arr: seq[int]
  for i in 0 ..< numSamples:
    arr.add(probs.sample())
  return arr.toTensor()


#echo p.multinomial(20)

# let ix = p.sample()
# echo itos[ix]

var P = N.map(x => x.float)


for i in 0 ..< 28:
  let row = P[i, _]
  echo i, ":", sum(row)
  P[i, _] = row / sum(row)

# echo "sum zero axis? ", P.cumsum(0)[27, _]
# P = P / (P.cumsum(0)[27, _])

for i in 0 ..< 20:
  var name = ""
  var ix = 0
  while true:
    var p = P[ix, _].reshape([28])
    ix = p.sample()
    name.add(itos[ix])
    if ix == 0:
      break
  echo name
