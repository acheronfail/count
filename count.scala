object Count {
    def main(args: Array[String]) = {
        var num = 0
        while (num < 1_000_000_000) {
          num += 1
        }

        println(num)
    }
}
