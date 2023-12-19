object count {
    def main(args: Array[String]) = {
        var num = 0
        val target = args(0).toInt
        while (num < target) {
          num += 1
        }

        println(num)
    }
}
