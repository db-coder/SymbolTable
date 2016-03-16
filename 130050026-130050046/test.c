struct s {
    int a;
    float b[5][5];
};

struct t{
    struct s x[10];
};

float * f(int * a[10], float b[8][5]) {
    return b[0];
}

int main() {
    float a[10][5];
    int b[10][10];
    int * c[5];
    struct s x;
    struct t y;
    int i;
    f(c, x.b);
    f(c, a);
}
