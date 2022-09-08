import std/sequtils, std/strutils, std/tables, std/sets, std/algorithm, pixie

let words = readFile("names.txt").split("\n")

# echo words[0 ..< 10]

# echo words.len

# echo min(words.mapIt(it.len))

# echo max(words.mapIt(it.len))

# for w in words[0 ..< 3]:
#   var chs = @["<S>"] & toSeq(w.mapIt($it)) & @["<E>"]
#   for i, (ch1, ch2) in zip(chs, chs[1..^1]):
#     echo ch1, " ", ch2
#     b.inc((ch1, ch2))

# var b: CountTable[(string, string)]
# for w in words:
#   var chs = @["<S>"] & toSeq(w.mapIt($it)) & @["<E>"]
#   for i, (ch1, ch2) in zip(chs, chs[1..^1]):
#     b.inc((ch1, ch2))
# echo b
# b.sort()
# echo b

import arraymancer

# var a = zeros[int32]([3, 5])
# echo a

# a[1, 3] += 1
# a[1, 3] += 1
# a[1, 3] += 1
# a[0, 0] = 5

# echo a

var N = zeros[int32]([28, 28])

let chars = words.join("").toHashSet().toSeq().sorted()
#echo chars
var stoi: Table[string, int]
for i, c in chars:
  stoi[$c] = i
stoi["<S>"] = 26
stoi["<E>"] = 27
#echo stoi

var itos: Table[int, string]
for s, i in stoi:
  itos[i] = s

echo itos

for w in words:
  var chs = @["<S>"] & toSeq(w.mapIt($it)) & @["<E>"]
  for i, (ch1, ch2) in zip(chs, chs[1..^1]):
    let
      ix1 = stoi[ch1]
      ix2 = stoi[ch2]
    N[ix1, ix2] += 1

# echo N

# heat map

var figure = newImage(60*28, 60*28)
let ctx = newContext(figure)
ctx.font = "Roboto-Regular_1.ttf"
ctx.fontSize = 18

let maxCount = max(N)
echo maxCount

let
  lowColor = "#FFFFFF".parseHtmlHex()
  highColor = "#2980b9".parseHtmlHex()

for x in 0 ..< 28:
  for y in 0 ..< 28:

    ctx.fillStyle = mix(lowColor, highColor, sqrt(N[y, x].float32 / maxCount.float32))
    ctx.fillRect(x.float32*60, y.float32*60, 60, 60)

    ctx.fillStyle = "#2c3e50"

    ctx.fillText(
      itos[y] & itos[x],
      x.float32*60 + 30 - ctx.measureText(itos[y] & itos[x]).width / 2,
      y.float32*60 + 25
    )
    ctx.fillText(
      $N[y, x],
      x.float32*60 + 30 - ctx.measureText($N[y, x]).width / 2,
      y.float32*60 + 45
    )

figure.writeFile("figure.png")
