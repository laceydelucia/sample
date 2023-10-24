  .section .rodata

//----------------------------------------------------------------------

        .section .data

//----------------------------------------------------------------------

        .section .bss

//----------------------------------------------------------------------

        .section .text

    // Must be a multiple of 16
        .equ    MAX_DIGITS, 32768
        .equ    ADD_STACK_BYTECOUNT, 96
        .equ    TRUE, 1
        .equ    FALSE, 0
        
        // Local variables stack offsets:
        INPUT1      .req x20
        LINDEX      .req x21
        LSUMLENGTH  .req x22

     // Parameter stack offsets:
        OADDEND1    .req x23
        OADDEND2    .req x24
        OSUM        .req x25
        INPUT2      .req x26
        ARRAY1      .req x27
        ARRAY2      .req x28
        ARRAY3      .req x19
        
    // struct offsets
        .equ    LLEN, 0
        .equ    ARRAY, 8

        .global BigInt_add

BigInt_add:
        // Prolog
        sub     sp, sp, ADD_STACK_BYTECOUNT
        str     x30, [sp]

        str     x20, [sp, 8]
        str     x21, [sp, 16]
        str     x22, [sp, 24]
        str     x23, [sp, 32]
        str     x24, [sp, 40]
        str     x25, [sp, 48]
        str     x26, [sp, 56]
        str     x27, [sp, 64]
        str     x28, [sp, 72]
        str     x19, [sp, 80]
    

        mov     OADDEND1, x0
        mov     OADDEND2, x1
        mov     OSUM, x2

        mov     x0, 0
        adds    x0, x0, x0


     //lSumLength = BigInt_larger(oAddend1->lLength, oAddend2->lLength);
        ldr     x0, [OADDEND1, LLEN]
        ldr     x1, [OADDEND2, LLEN]

    //if (lLength1 <= lLength2) go to largerElse
        cmp     x0, x1
        ble     largerElse
        mov     LSUMLENGTH, x0
        b       largerEnd
        
    largerElse:
        mov     LSUMLENGTH, x1
    largerEnd:

    // if (oSum->lLength <= lSumLength) goto else2;
        ldr     x2, [OSUM, LLEN]
        cmp     x2, x0
        ble     else2
    // memset(oSum->aulDigits, 0, MAX_DIGITS * sizeof(unsigned long));
        mov     x0, OSUM
        add     x0, x0, ARRAY
        mov     w1, 0
        mov     x2, MAX_DIGITS
        lsl     x2, x2, 3
        bl      memset

    else2:
        mov     LINDEX, 0
        mov     x1, 0

        add     ARRAY3, OSUM, ARRAY
        add     ARRAY1, OADDEND1, ARRAY
        add     ARRAY2, OADDEND2, ARRAY

        ldr     INPUT1, [ARRAY1, LINDEX, lsl 3]
        ldr     INPUT2, [ARRAY2, LINDEX, lsl 3]
        adds    x1, INPUT1, INPUT2
        str     x1, [ARRAY3, LINDEX]

        eor     x3, LSUMLENGTH, LINDEX
        cbz     x3, endloop1 

    // lIndex = 1;
        mov     LINDEX, 1
        
     // if (lIndex >= lSumLength) goto endloop1;
        eor     x3, LSUMLENGTH, LINDEX
        cbz     x3, endloop1  
    
        
    loop1: 
        // adcs(oAddend1, oAddend1, oAddend2 )
    //adds    x1, INPUT1, INPUT2
        ldr     INPUT1, [ARRAY1, LINDEX, lsl 3]
        ldr     INPUT2, [ARRAY2, LINDEX, lsl 3]

        adcs    x2, INPUT1, INPUT2

    // oSum->aulDigits[lIndex] = ulSum;
        str     x2, [ARRAY3, LINDEX, lsl 3]

    //lIndex++
        add     LINDEX, LINDEX, 1
    // goto Loop1
        eor     x3, LSUMLENGTH, LINDEX
        cbnz    x3, loop1
        

        
    //cmp     LSUMLENGTH, LINDEX
    //bgt     loop1 
        
    endloop1:
    // if C==1 go to else5;
        cmp     INPUT1, INPUT2
        ble     largerInputElse
        mov     x3, INPUT2
        b       largerInputEnd 
    largerInputElse:
        mov     x3, INPUT1
    largerInputEnd:
        cmp x1, x3
        bhs     else5
        
    // if (lSumLength != MAX_DIGITS) goto else6;
        cmp     LSUMLENGTH, MAX_DIGITS
        bne     else6
    // return FALSE;
        mov     w0, FALSE
        ldr     x30, [sp]
        ldr     x20, [sp, 8]
        ldr     x21, [sp, 16]
        ldr     x22, [sp, 24]
        ldr     x23, [sp, 32]
        ldr     x24, [sp, 40]
        ldr     x25, [sp, 48]
        ldr     x26, [sp, 56]
        ldr     x27, [sp, 64]
        ldr     x28, [sp, 72]
        ldr     x19, [sp, 80]
      
        add     sp, sp, ADD_STACK_BYTECOUNT
        ret

    else6:
    // oSum->aulDigits[lSumLength] = 1;
        mov     x5, 1
        str     x5, [ARRAY3, LSUMLENGTH, lsl 3]
    // lSumLength++;
        add     LSUMLENGTH, LSUMLENGTH, 1
      

    else5:
    //oSum->lLength = lSumLength;
        str     LSUMLENGTH, [OSUM, LLEN]

    //ret TRUE

        mov     w0, TRUE
        ldr     x30, [sp]
        ldr     x20, [sp, 8]
        ldr     x21, [sp, 16]
        ldr     x22, [sp, 24]
        ldr     x23, [sp, 32]
        ldr     x24, [sp, 40]
        ldr     x25, [sp, 48]
        ldr     x26, [sp, 56]
        ldr     x27, [sp, 64]
        ldr     x28, [sp, 72]
        ldr     x19, [sp, 80]
        add     sp, sp, ADD_STACK_BYTECOUNT
        ret

        .size   BigInt_add, (. - BigInt_add)












        
        

