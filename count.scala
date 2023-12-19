object count {
    def main(args: Array[String]) = {
        var num = 0
        val target = args(0).toInt
        while (num < target) {
          num = (num + 1) % 2000000000
        }

        println(num)
    }
}
