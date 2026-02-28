#include <vector>
#include <unordered_map>
#include <cstdio>
#include <cstdlib>
#include <cmath>
#include <climits>

#define ll long long

struct tree
{
    ll val;
    tree *left, *right;
    tree(ll v) : val(v), left(nullptr), right(nullptr) {}
};

tree *mk_tree(FILE *f)
{ // creates a tree from input file
    ll num;
    fscanf(f, "%lld", &num);
    if (num)
    {
        tree *t = new tree(num);
        t->left = mk_tree(f);
        t->right = mk_tree(f);
        return t;
    }
    else
        return nullptr;
}

// This function finds the minimum node value in a tree

ll min_value(tree *t)
{
    if (t == nullptr)
        return LLONG_MAX;
    ll l = t->left ? min_value(t->left) : LLONG_MAX;
    ll r = t->right ? min_value(t->right) : LLONG_MAX;
    // If the node is a leaf node, return 0
    return std::min(t->val, std::min(l, r));
}

/* Re-arranging tree nodes
 * If the minimum of the left subtree is greater than the minimum of the right subtree, swap them
 * If a node is a leaf node, check whether it is greater or less than parent node. If it is greater, it should be on the right side. If it is less, it should be on the left side.
 */

void arrange(tree *t)
{
    if (t == nullptr)
        return;
    arrange(t->left);
    arrange(t->right);

    ll minLeft = min_value(t->left);
    ll minRight = min_value(t->right);

    /*Swap if the minimum of the left subtree is greater than the minimum of the right subtree, and both nodes are not leaf nodes.
     */
    if (t->left != nullptr && t->right != nullptr && minRight < minLeft)
    {
        tree *temp = t->left;
        t->left = t->right;
        t->right = temp;
    }

    /*Corner case:
     * If a parent node has only one child, the child should be on the right side if it is greater than the parent node. If it is less, it should be on the left side.
     */

    else if (t->left == nullptr && t->right != nullptr) 
    {
        if (t->val > t->right->val)
        {
            tree *temp = t->right;
            t->right = nullptr;
            t->left = temp;
        }
    }

    else if (t->right == nullptr && t->left != nullptr)
    {
        if (t->val < t->left->val)
        {
            tree *temp = t->left;
            t->left = nullptr;
            t->right = temp;
        }
    }
}

void print_tree(tree *t, bool &first)
{
    if (t == nullptr)
        return;
    print_tree(t->left, first);
    printf(first ? "%lld" : " %lld", t->val);
    first = false;
    print_tree(t->right, first);
}

int main(int argc, char **argv)
{
    if (argc != 2)
    {
        printf("Usage: %s <input_file>\n", argv[0]);
        return 1;
    }
    FILE *f = fopen(argv[1], "r");
    if (f == NULL)
    {
        printf("Error opening file\n");
        return 1;
    }
    ll N;
    fscanf(f, "%lld", &N);
    tree *t = mk_tree(f);
    fclose(f);
    arrange(t);
    bool first = true;
    print_tree(t, first);
    printf("\n");
}