import std/sequtils, std/strutils, std/tables, std/sets, std/algorithm, pixie,
    arraymancer, std/sugar

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
var NFloat = N[0, _].reshape([28]).map(x => x.float) / sum(N[0, _]).float
echo NFloat
echo NFloat.sum()
