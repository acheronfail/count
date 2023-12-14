public class count {

	public static void main(String[] args){
    int i = 0;
    while (i < 1_000_000_000) {
      i += 1;
    }

    System.out.println(i);
	}
}