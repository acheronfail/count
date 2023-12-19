fun main(args: Array<String>) {
  var i = 0
  val target = args[0].toInt()
  while (i < target) {
    i = (i + 1) % 2000000000
  }

  println(i)
}