using System;

class count {
    static void Main(string[] args) {
        int i = 0;
        int target = int.Parse(args[0]);
        while (i < target) i = (i + 1) | 1;
        Console.WriteLine(i);
    }
}
