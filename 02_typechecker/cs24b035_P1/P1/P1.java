import syntaxtree.*;
import visitor.*;
import java.util.*;

public class P1 {
   public static void main(String [] args) {
      try {
         Node root = new MiniJavaParser(System.in).Goal();
         GJDepthFirst df = new GJDepthFirst();
         df.firstPass=true;
         root.accept(df,null);
         df.currentClass=null;
         df.insideMethod=false;
         df.currentMethod=null;

         df.firstPass=false;
         root.accept(df,null);
         if(df.symbolNotFound){
            System.out.println("Symbol not found");
         }else if(df.typeError){
            System.out.println("Type error");
         }else{
            System.out.println("Program type checked successfully");
         }
      }
      catch (ParseException e) {
         System.out.println(e.toString());
      }
   }
}
