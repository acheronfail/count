public class count {
	public static void main(String[] args){
    int i = 0;
    int target = Integer.parseInt(args[0]);
    while (i < target) {
        i = (i + 1) | 1;
    }

    System.out.println(i);
	}
}