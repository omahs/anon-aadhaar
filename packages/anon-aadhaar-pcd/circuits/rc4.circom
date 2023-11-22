pragma circom 2.1.5;


template RC4(text_size, key_size) {
    signal input key[key_size];
    signal input inp[text_size];
    signal output out[text_size];
    var s[256];

    var j = 0;
    var i = 0;
    for (i = 0; i < 256; i++) {
        s[i] = i;        
    }

    var tmp;
    for (i = 0; i < 256; i++) {
        j = (j + s[i] + key[i % key_size]) % 256;
        tmp = s[i];
        s[i] = s[j];
        s[j] = tmp;
    }

    i = 0; j = 0;

    var t; 
    for (var n = 0; n < text_size; n++) {
        i = (i + 1) % 256;
        j = (j + s[i]) % 256; 
        tmp = s[i];
        s[i] = s[j];
        s[j] = tmp;
        t = (s[i] + s[j]) % 256;
        out[n] <-- inp[n] ^ s[t];
    }

}


component main = RC4(9, 3);