struct s {
    int a;
    float b[5][5];
};

struct t{
    struct s x[10];
};

float * f(int * a[10], float b[8][5]) {
	float *p;
    return p;
}

int main() {
    float a[10][10];
    int b[10][10];
    int * c[5];
    struct s x;
    struct t y;
    int i;
    f(c, a);
    y.x[i].b[2] = x.b[1];
}
