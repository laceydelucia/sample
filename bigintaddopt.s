        .section .rodata

//----------------------------------------------------------------------

        .section .data

//----------------------------------------------------------------------

        .section .bss

//----------------------------------------------------------------------

        .section .text
        // Must be a multiple of 16
        .equ    LARGER_STACK_BYTECOUNT, 32

        // Local variable stack offsets:
        .equ    LLARGER, 8

        // Parameter stack offsets:
        .equ    LLENGTH2, 16
        .equ    LLENGTH1, 24
        

BigInt_larger:
        // Prolog
        sub     sp, sp, LARGER_STACK_BYTECOUNT
        str     x30, [sp]
        // if (lLength1 <= lLength2) goto else1;
        cmp     x0, x1
        ble     else1
        // lLarger = lLength1; (already in x0)
        // goto end1;
        b       end

    else1:
        // lLarger = lLength2;
        mov     x0, x1

    end:
     // Epilog and return lLarger
        ldr     x30, [sp]
      
        add     sp, sp, LARGER_STACK_BYTECOUNT
        ret

        .size   BigInt_larger, (. - BigInt_larger)
        


    // Must be a multiple of 16
        .equ    MAX_DIGITS, 32768
        .equ    ADD_STACK_BYTECOUNT, 64
        .equ    TRUE, 1
        .equ    FALSE, 0
        
        // Local variables stack offsets:
        ULCARRY     .req x19
        ULSUM       .req x20
        LINDEX      .req x21
        LSUMLENGTH  .req x22

     // Parameter stack offsets:
        OADDEND1    .req x23
        OADDEND2    .req x24
        OSUM        .req x25
        
    // struct offsets
        .equ    LLEN, 0
        .equ    ARRAY, 8

        .global BigInt_add

BigInt_add:
        // Prolog
        sub     sp, sp, ADD_STACK_BYTECOUNT
        str     x30, [sp]

        str     x19, [sp, 8]
        str     x20, [sp, 16]
        str     x21, [sp, 24]
        str     x22, [sp, 32]
        str     x23, [sp, 40]
        str     x24, [sp, 48]
        str     x25, [sp, 56]

        mov     OADDEND1, x0
        mov     OADDEND2, x1
        mov     OSUM, x2


     //lSumLength = BigInt_larger(oAddend1->lLength, oAddend2->lLength);
        ldr     x0, [OADDEND1, LLEN]
        ldr     x1, [OADDEND2, LLEN]
        bl      BigInt_larger
        mov     LSUMLENGTH, x0
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
    // ulCarry = 0;
    // lIndex = 0;
        mov     ULCARRY, 0
        mov     LINDEX, 0

    loop1: 
    // if (lIndex >= lSumLength) goto endloop1;
        cmp     LINDEX, LSUMLENGTH
        bge     endloop1
    // ulSum = ulCarry;
        mov ULSUM, ULCARRY
    // ulCarry = 0;
        mov     ULCARRY, 0
    // ulSum += oAddend1->aulDigits[lIndex];
        add     x2, OADDEND1, ARRAY
        ldr     x2, [x2, LINDEX, lsl 3]
        add     ULSUM, ULSUM, x2

    // if (ulSum >= oAddend1->aulDigits[lIndex]) goto else3;
        cmp     ULSUM, x2
        bhs     else3
    // ulCarry = 1;
        mov     ULCARRY, 1

    else3:
        // ulSum += oAddend2->aulDigits[lIndex];
        add     x3, OADDEND2, ARRAY
        ldr     x3, [x3, LINDEX, lsl 3]
        add     ULSUM, ULSUM, x3
    // if (ulSum >= oAddend2->aulDigits[lIndex]) goto else4;
        cmp     ULSUM, x3
        bhs     else4
    // ulCarry = 1;
        mov     ULCARRY, 1
    else4:
    // oSum->aulDigits[lIndex] = ulSum;
        add     x4, OSUM, ARRAY
        str     ULSUM, [x4, LINDEX, lsl 3]
    //lIndex++
        add     LINDEX, LINDEX, 1
    // goto Loop1
        b       loop1

    endloop1:
    // if (ulCarry != 1) goto else5;
         cmp     ULCARRY, 1
         bne     else5
    // if (lSumLength != MAX_DIGITS) goto else6;
        cmp     LSUMLENGTH, MAX_DIGITS
        bne     else6
    // return FALSE;
        mov     w0, FALSE
        ldr     x30, [sp]
        ldr     x19, [sp, 8]
        ldr     x20, [sp, 16]
        ldr     x21, [sp, 24]
        ldr     x22, [sp, 32]
        ldr     x23, [sp, 40]
        ldr     x24, [sp, 48]
        ldr     x25, [sp, 56]
        add     sp, sp, ADD_STACK_BYTECOUNT
        ret

    else6:
    // oSum->aulDigits[lSumLength] = 1;
        mov     x2, 1
        str     x2, [x4, LSUMLENGTH, lsl 3]
    // lSumLength++;
        add     LSUMLENGTH, LSUMLENGTH, 1
      

    else5:
    //oSum->lLength = lSumLength;
        str     LSUMLENGTH, [OSUM, LLEN]

    //ret TRUE

        mov     w0, TRUE
        ldr     x30, [sp]
        ldr     x19, [sp, 8]
        ldr     x20, [sp, 16]
        ldr     x21, [sp, 24]
        ldr     x22, [sp, 32]
        ldr     x23, [sp, 40]
        ldr     x24, [sp, 48]
        ldr     x25, [sp, 56]
        add     sp, sp, ADD_STACK_BYTECOUNT
        ret

        .size   BigInt_add, (. - BigInt_add)












        
        

