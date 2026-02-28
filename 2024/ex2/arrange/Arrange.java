import java.util.*;
import java.io.*;

public class Arrange {
    
    static class TreeNode {
        long val;
        TreeNode left;
        TreeNode right;
        TreeNode(long x) { 
            val = x; 
            left = right = null;
        }
    }

    public static TreeNode mkTree(Scanner sc) {
        if (!sc.hasNextLong()) return null;
        long val = sc.nextLong();
        if (val != 0) {
            TreeNode root = new TreeNode(val);
            root.left = mkTree(sc);
            root.right = mkTree(sc);
            return root;
        }
        return null;
    }

    public static long minValue(TreeNode root) {
        if (root == null) {
            return Long.MAX_VALUE;
        }
        long l = root.left != null ? minValue(root.left) : Long.MAX_VALUE;
        long r = root.right != null ? minValue(root.right) : Long.MAX_VALUE;
        return Math.min(root.val, Math.min(l, r));
    }

    public static void arrange(TreeNode root) {
        if (root == null) return;

        arrange(root.left);
        arrange(root.right);

        long minLeft = minValue(root.left);
        long minRight = minValue(root.right);

        if (root.left != null && root.right != null && minRight < minLeft) {
            TreeNode tmp = root.left;
            root.left = root.right;
            root.right = tmp;
        }

        else if (root.left != null && root.right == null && root.left.val > root.val) {
            TreeNode tmp = root.left;
            root.left = root.right;
            root.right = tmp;
        }

        else if (root.left == null && root.right != null && root.right.val < root.val) {
            TreeNode tmp = root.right;
            root.right = root.left;
            root.left = tmp;
        }
    }

    public static void printInorder(TreeNode root, boolean[] first) {
        if (root == null) return;
        printInorder(root.left, first);
        if (first[0]) {
            System.out.print(root.val + " ");
            first[0] = false;
        }
        else {
            System.out.print(root.val + " ");
        }
        printInorder(root.right, first);
    }

    public static void main (String[] args) {
        if (args.length != 1) {
            System.out.println("Usage: java Arrange <input file>");
            System.exit(1);
        }
        try (Scanner sc = new Scanner(new File(args[0]))) {
            if (!sc.hasNextLong()) {
                System.out.println("Empty input file");
                System.exit(1);
            }
            long N = sc.nextLong();
            TreeNode root = mkTree(sc);
            arrange(root);
            boolean[] first = {true};
            printInorder(root, first);
            System.out.println();
        } catch (FileNotFoundException e) {
            System.out.println("No such file: " + args[0]);
            System.exit(1);
        }
    }
}
