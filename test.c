struct s {
    int a;
    float b;
};
struct t {
    int a;
    float b;
};
int f(int m, float n) {
    struct s x;
    struct s y;
    struct t z;
    int p,r;
    float q;
    (p+r)++;
    p = p;
    q = 1.0 + z.a;
    f(z.b, z.a);
}
struct u {
    struct s * a;
    struct t * b;
    struct u * c;
};
int g(int a) {
    struct u x;
    return 1.9;
}
int h()
{
    int x;
    x = h();
}