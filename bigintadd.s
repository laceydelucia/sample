
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
        str     x0, [sp, LLENGTH1]
        str     x1, [sp, LLENGTH2]

        //if (lLength1 <= lLength2) goto else1;
        ldr     x1, [sp, LLENGTH1]
        ldr     x2, [sp, LLENGTH2]
        cmp     x1, x2
        ble     else1

        // lLarger = lLength1;
        str     x1, [sp, LLARGER]
        // goto end
        b       end

    else1:
        // lLarger = lLength2;
        str     x2, [sp, LLARGER]

    end:
     // Epilog and return lLarger
        ldr     x0, [sp, LLARGER]
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
        .equ    ULCARRY,  8
        .equ    ULSUM,    16
        .equ    LINDEX,    24
        .equ    LSUMLENGTH, 32

     // Parameter stack offsets:
        
        .equ    OADDEND1, 40
        .equ    OADDEND2, 48
        .equ    OSUM, 56
       
    // struct offsets
        .equ    LLEN, 0
        .equ    ARRAY, 8

        .global BigInt_add

BigInt_add:
        // Prolog
        sub     sp, sp, ADD_STACK_BYTECOUNT
        str     x30, [sp]
        str     x0, [sp, OADDEND1]
        str     x1, [sp, OADDEND2]
        str     x2, [sp, OSUM]

     //lSumLength = BigInt_larger(oAddend1->lLength, oAddend2->lLength);
        ldr     x0, [sp, OADDEND1]
        ldr     x0, [x0, LLEN]
        ldr     x1, [sp, OADDEND2]
        ldr     x1, [x1, LLEN]
        bl      BigInt_larger
        str     x0, [sp, LSUMLENGTH]
    // if (oSum->lLength <= lSumLength) goto else2;
        ldr     x1, [sp, OSUM]
        ldr     x1, [x1, LLEN]
        cmp     x1, x0
        ble     else2
    // memset(oSum->aulDigits, 0, MAX_DIGITS * sizeof(unsigned long));
        ldr     x0, [sp, OSUM]
        add     x0, x0, ARRAY
        mov     w1, 0
        mov     x2, MAX_DIGITS
        lsl     x2, x2, 3
        bl      memset
    else2:
    // ulCarry = 0;
    // lIndex = 0;
        mov     x1, 0
        str     x1, [sp, ULCARRY]
        str     x1, [sp, LINDEX]

    loop1: 
    // if (lIndex >= lSumLength) goto endloop1;
        ldr     x0, [sp, LINDEX]
        ldr     x1, [sp, LSUMLENGTH]
        cmp     x0, x1
        bge     endloop1
    // ulSum = ulCarry;
        ldr     x0, [sp, ULCARRY]
        str     x0, [sp, ULSUM]
    // ulCarry = 0;
        mov     x0, 0
        str     x0, [sp, ULCARRY]
    // ulSum += oAddend1->aulDigits[lIndex];
        ldr     x0, [sp, OADDEND1]
        add     x0, x0, ARRAY
        ldr     x1, [sp, LINDEX] 
        ldr     x0, [x0, x1, lsl 3]
    
        ldr     x2, [sp, ULSUM]
        add     x2, x2, x0
        str     x2, [sp, ULSUM]
    // if (ulSum >= oAddend1->aulDigits[lIndex]) goto else3;
        cmp     x2, x0
        bhs     else3
    // ulCarry = 1;
        mov     x1, 1
        str     x1, [sp, ULCARRY]

    else3:
        // ulSum += oAddend2->aulDigits[lIndex];
        ldr     x0, [sp, OADDEND2]
        add     x0, x0, ARRAY
        ldr     x1, [sp, LINDEX] 
        ldr     x0, [x0, x1, lsl 3]
    
        ldr     x2, [sp, ULSUM]
        add     x2, x2, x0
        str     x2, [sp, ULSUM]
    // if (ulSum >= oAddend2->aulDigits[lIndex]) goto else4;
        cmp     x2, x0
        bhs     else4
    // ulCarry = 1;
        mov     x1, 1
        str     x1, [sp, ULCARRY]
    else4:
    // oSum->aulDigits[lIndex] = ulSum;
        ldr     x0, [sp, OSUM]
        add     x0, x0, ARRAY
        ldr     x1, [sp, LINDEX] 

        ldr     x2, [sp, ULSUM]
        str     x2, [x0, x1, lsl 3]
    //lIndex++
        ldr     x0, [sp, LINDEX]
        add     x0, x0, 1
        str     x0, [sp, LINDEX]
    // goto Loop1
        b       loop1

    endloop1:
    // if (ulCarry != 1) goto else5;
         ldr     x0, [sp, ULCARRY]
         cmp     x0, 1
         bne     else5
    // if (lSumLength != MAX_DIGITS) goto else6;
        ldr     x0, [sp, LSUMLENGTH]
        cmp     x0, MAX_DIGITS
        bne     else6
    // return FALSE;
        mov     w0, FALSE
        ldr     x30, [sp]
        add     sp, sp, ADD_STACK_BYTECOUNT
        ret

    else6:
    // oSum->aulDigits[lSumLength] = 1;
        ldr     x0, [sp, OSUM]
        add     x0, x0, ARRAY
        ldr     x1, [sp, LSUMLENGTH] 
        mov     x2, 1
        str     x2, [x0, x1, lsl 3]
    // lSumLength++;
        ldr     x0, [sp, LSUMLENGTH]
        add     x0, x0, 1
        str     x0, [sp, LSUMLENGTH]

    else5:
    //oSum->lLength = lSumLength;
        ldr     x0, [sp, OSUM]
        ldr     x2, [sp, LSUMLENGTH]
        str     x2, [x0, LLEN]

    //ret TRUE

        mov     w0, TRUE
        ldr     x30, [sp]
        add     sp, sp, ADD_STACK_BYTECOUNT
        ret

        .size   BigInt_add, (. - BigInt_add)












        
        

