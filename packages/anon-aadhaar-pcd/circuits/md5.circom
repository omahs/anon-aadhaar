pragma circom 2.1.5;

// Rotate 
template Rotate() {
    signal input num; 
    signal output rotate_number;   
    signal input s;
    
    rotate_number <-- (num << s) | (num >> (32 - s));
}


// (a + b) % 32;
// check security later
template AddMod32() {
    signal input a;
    signal input b;
    signal output c;
    signal sum;
    signal q; 
    var m = 1 << 32;
    sum <== a + b;

    q <-- sum \ m;

    c <-- sum % m;

    sum === q * m + c;
}

template Add2Mod32() {
    signal input a;
    signal input b;
    signal input c; 
    signal input d; 

    component x = AddMod32(); 
    x.a <== a; 
    x.b <== b; 
    
    component y = AddMod32();
    y.a <== c;
    y.b <== d; 

    component z = AddMod32();
    z.a <== x.c; 
    z.b <== y.c;

    signal output r; 

    r <== z.c;    
}

function not(a) {
    var ans = 0;
    for (var i = 125; i >= 0; i--) {
        if (a & (1 << i) == 0) {
            ans += (1 << i);
        }
    }
    return ans;
}

template FF() {
    signal input A_in;
    signal input B_in;
    signal input C_in; 
    signal input D_in; 

    signal output B_out;
    signal output C_out; 
    signal output D_out; 

    signal input s; 
    signal input x; 
    signal input t; 

    signal output A_out;
    
    // a = b + ((a + F(b, c, d) + X[k] + T[i]) <<< s)
    
    signal f; 
    f <-- (B_in & C_in) | (not(B_in) & D_in);


    component add2 = Add2Mod32();
    add2.a <== A_in;
    add2.b <== f;
    add2.c <== x;
    add2.d <== t;

    component rotate = Rotate();
    rotate.num <== add2.r;
    rotate.s <== s;

    component add = AddMod32();
    add.a <== B_in; 
    add.b <== rotate.rotate_number;

    A_out <== add.c;    
    B_out <== B_in;
    C_out <== C_in;
    D_out <== D_in;
}

template GG() {
    signal input A_in;
    signal input B_in;
    signal input C_in; 
    signal input D_in; 
    signal input s;
    signal input x; 
    signal input t; 

    signal output A_out;

    
    signal output B_out;
    signal output C_out; 
    signal output D_out; 
     
    // a = b + ((a + G(b, c, d) + X[k] + T[i]) <<< s)
    
    signal f; 
    f <-- (B_in & D_in)  | (C_in & not(D_in));

    component add2 = Add2Mod32();
    add2.a <== A_in;
    add2.b <== f;
    add2.c <== x;
    add2.d <== t;

    component rotate = Rotate();
    rotate.s <== s;
    rotate.num <== add2.r;

    component add = AddMod32();

    add.a <== B_in; 
    add.b <== rotate.rotate_number;

    A_out <== add.c;
  B_out <== B_in;
    C_out <== C_in;
    D_out <== D_in;  
}


template HH() {

    signal output B_out;
    signal output C_out; 
    signal output D_out; 

    signal input A_in;
    signal input B_in;
    signal input C_in; 
    signal input D_in; 
    signal input s;
    signal input x; 
    signal input t; 

    signal output A_out;
    
    // a = b + ((a + G(b, c, d) + X[k] + T[i]) <<< s)
    
    signal h; 
    h <-- (B_in  ^ C_in ^ D_in);

    component add2 = Add2Mod32();
    add2.a <== A_in;
    add2.b <== h;
    add2.c <== x;
    add2.d <== t;

    component rotate = Rotate();
    rotate.num <== add2.r;
    rotate.s <== s;

    component add = AddMod32();

    add.a <== B_in; 
    add.b <== rotate.rotate_number;

    A_out <== add.c;    
      B_out <== B_in;
    C_out <== C_in;
    D_out <== D_in;
}

template II() {


    signal output B_out;
    signal output C_out; 
    signal output D_out; 

    signal input A_in;
    signal input B_in;
    signal input C_in; 
    signal input D_in; 
    signal input s;
    signal input x; 
    signal input t; 

    signal output A_out;
    
    // a = b + ((a + G(b, c, d) + X[k] + T[i]) <<< s)
    
    signal i; 
    i <-- (C_in ^ (B_in | not(D_in)));

    component add2 = Add2Mod32();
    add2.a <== A_in;
    add2.b <== i;
    add2.c <== x;
    add2.d <== t;

    component rotate = Rotate();
    rotate.num <== add2.r;
    rotate.s <== s;

    component add = AddMod32();

    add.a <== B_in; 
    add.b <== rotate.rotate_number;

    A_out <== add.c;    
    B_out <== B_in;
    C_out <== C_in;
    D_out <== D_in;
}


template md5(N) {
    signal input m[N];
    signal output hash; // md5 hash function result

    signal X[N/16][16];

    signal A[N/16 + 1];
    signal B[N/16 + 1];
    signal C[N/16 + 1];
    signal D[N/16 + 1];

    A[0] <== 0x67452301;
    B[0] <== 0xefcdab89;
    C[0] <== 0x98badcfe;
    D[0] <== 0x10325476;


    component FFs[N/16][16];
    component GGs[N/16][16];
    component HHs[N/16][16];
    component IIs[N/16][16];
    component addA[N/16];
    component addB[N/16];
    component addC[N/16];
    component addD[N/16];

    var T_value[64] = [
        0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee, 0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501, 
    0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be, 
 0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821, 
 0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa, 
 0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8, 
0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed, 
 0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a, 
 0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c, 
 0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70, 
 0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x04881d05, 
 0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665,
 0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039, 
 0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1, 
0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1,
0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391
    ];


    var s_values[64] = [
        7, 12, 17, 22,  7, 12, 17, 22,  7, 12, 17, 22,  7, 12, 17, 22,
5,  9, 14, 20,  5,  9, 14, 20,  5,  9, 14, 20,  5,  9, 14, 20, 
4, 11, 16, 23,  4, 11, 16, 23,  4, 11, 16, 23,  4, 11, 16, 23, 
6, 10, 15, 21,  6, 10, 15, 21,  6, 10, 15, 21,  6, 10, 15, 21
    ];

    var x_ids[64] = [
        0, 1, 2,  3, 4,  5,  6, 7, 8,  9, 10, 11, 12, 13, 14, 15,
        1, 6, 11, 0, 5, 10, 15, 4, 9, 14,  3,  8, 13,  2,  7, 12,
        5, 8, 11,14, 1,  4,  7,10,13,  0,  3,  6,  9, 12, 15,  2,
        0, 7, 14, 5, 12, 3, 10, 1, 8, 15,  6, 13,  4, 11,  2,  9 
    ];

    for (var i = 0; i < N / 16; i++) {
   
        for (var j = 0; j < 16; j++) {
            X[i][j] <== m[i * 16 + j];
        }


        for (var k = 0; k < 16; k++) {
            FFs[i][k] = FF();
            GGs[i][k] = GG();
            HHs[i][k] = HH();
            IIs[i][k] = II();
        }
        
        var count = 0;

        FFs[i][0].A_in <== A[i];
        FFs[i][0].B_in <== B[i]; 
        FFs[i][0].C_in <== C[i];
        FFs[i][0].D_in <== D[i];
        FFs[i][0].x <== X[i][x_ids[count]];
        FFs[i][0].s <== s_values[count];
        FFs[i][0].t <== T_value[count];

     
        for (var k = 1; k < 16; k++) {
            // magical...
            FFs[i][k].A_in <== FFs[i][k - 1].D_out;
            FFs[i][k].B_in <== FFs[i][k - 1].A_out;
            FFs[i][k].C_in <== FFs[i][k - 1].B_out;
            FFs[i][k].D_in <== FFs[i][k - 1].C_out; 
        
            count++;
            FFs[i][k].x <== X[i][x_ids[count]];
            FFs[i][k].s <== s_values[count];
            FFs[i][k].t <== T_value[count]; 
        }
   


        GGs[i][0].A_in <== FFs[i][15].D_out;
        GGs[i][0].B_in <== FFs[i][15].A_out; 
        GGs[i][0].C_in <== FFs[i][15].B_out;
        GGs[i][0].D_in <== FFs[i][15].C_out;

        count++;
        GGs[i][0].x <== X[i][x_ids[count]];
        GGs[i][0].s <== s_values[count];
        GGs[i][0].t <== T_value[count];

        for (var k = 1; k < 16; k++) {
            // magical...
            GGs[i][k].A_in <== GGs[i][k - 1].D_out;
            GGs[i][k].B_in <== GGs[i][k - 1].A_out;
            GGs[i][k].C_in <== GGs[i][k - 1].B_out;
            GGs[i][k].D_in <== GGs[i][k - 1].C_out; 
        
            count++;
            GGs[i][k].x <== X[i][x_ids[count]];
            GGs[i][k].s <== s_values[count];
            GGs[i][k].t <== T_value[count]; 
        }
        
        HHs[i][0].A_in <== GGs[i][15].D_out;
        HHs[i][0].B_in <== GGs[i][15].A_out; 
        HHs[i][0].C_in <== GGs[i][15].B_out;
        HHs[i][0].D_in <== GGs[i][15].C_out;

        count++;
        HHs[i][0].x <== X[i][x_ids[count]];
        HHs[i][0].s <== s_values[count];
        HHs[i][0].t <== T_value[count];

         for (var k = 1; k < 16; k++) {
            // magical...
            HHs[i][k].A_in <== HHs[i][k - 1].D_out;
            HHs[i][k].B_in <== HHs[i][k - 1].A_out;
            HHs[i][k].C_in <== HHs[i][k - 1].B_out;
            HHs[i][k].D_in <== HHs[i][k - 1].C_out; 
        
            count++;
            HHs[i][k].x <== X[i][x_ids[count]];
            HHs[i][k].s <== s_values[count];
            HHs[i][k].t <== T_value[count]; 
        }

        IIs[i][0].A_in <== HHs[i][15].D_out;
        IIs[i][0].B_in <== HHs[i][15].A_out; 
        IIs[i][0].C_in <== HHs[i][15].B_out;
        IIs[i][0].D_in <== HHs[i][15].C_out;

        count++;
        IIs[i][0].x <== X[i][x_ids[count]];
        IIs[i][0].s <== s_values[count];
        IIs[i][0].t <== T_value[count];
        for (var k = 1; k < 16; k++) {
            // magical...
            IIs[i][k].A_in <== IIs[i][k - 1].D_out;
            IIs[i][k].B_in <== IIs[i][k - 1].A_out;
            IIs[i][k].C_in <== IIs[i][k - 1].B_out;
            IIs[i][k].D_in <== IIs[i][k - 1].C_out; 
        
            count++;
            IIs[i][k].x <== X[i][x_ids[count]];
            IIs[i][k].s <== s_values[count];
            IIs[i][k].t <== T_value[count]; 
        }
        addA[i] = AddMod32();
        addA[i].a <== A[i];
        addA[i].b <== IIs[i][15].D_out;
        A[i + 1] <== addA[i].c;

        addB[i] = AddMod32();
        addB[i].a <== B[i];
        addB[i].b <== IIs[i][15].A_out;
        B[i + 1] <== addB[i].c;

        addC[i] = AddMod32();
        addC[i].a <== C[i];
        addC[i].b <== IIs[i][15].B_out;
        C[i + 1] <== addC[i].c;

        addD[i] = AddMod32();
        addD[i].a <== D[i];
        addD[i].b <== IIs[i][15].C_out;
        D[i + 1] <== addD[i].c;
    } 

    var n = N / 16;
    var a = to_bigendian(A[n]);
    var b = to_bigendian(B[n]);
    var c = to_bigendian(C[n]);
    var d = to_bigendian(D[n]);
    hash <-- (a << 96) | (b << 64) | (c << 32) | d;
}


function to_bigendian(word) {
    return rl(word, 8) & 0x00FF00FF | rr(word, 8) & 0xFF00FF00; 
}

function rl(word, b) {
     return (word << b) | (word >> (32 - b));
}

function rr(word, b) {
    return (word << (32 - b)) | (word >> b);
}
component main = md5(16);