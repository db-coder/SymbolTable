struct s {
    int a;
    float b;
};
struct t {
    int a;
    float b;
};
void f(int m, float n) {
    struct s x;
    struct s y;
    struct t z;
    int p;
    int q;
    x = y;
    x.b = p;
    q = 1.0 + z.a;
    f(z.b, z.a);
}
int g(int a) {
    f(1, 0.1);
}
