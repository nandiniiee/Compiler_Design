import syntaxtree.*;
import visitor.*;
import java.util.*;

public class P2 {
   public static void main(String [] args) {
      try {
         Node root = new MiniJavaParser(System.in).Goal();
         GJDepthFirst df = new GJDepthFirst();
         Object value = root.accept(df, null); // Your assignment part is invoked here.
         if(value!=null){
            System.out.print(value.toString());
         }
      }
      catch (ParseException e) {
         System.out.println(e.toString());
      }
   }
}
