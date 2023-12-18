object count {
    def main(args: Array[String]) = {
        var num = 0
        while (num < 1000000000) {
          num += 1
        }

        println(num)
    }
}
