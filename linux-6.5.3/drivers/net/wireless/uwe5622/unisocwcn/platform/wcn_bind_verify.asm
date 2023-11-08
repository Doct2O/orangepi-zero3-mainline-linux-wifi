.section .text
.global wcn_bind_verify_calculate_verify_data
sha256_transform:
   stp   x29, x30, [sp, #-320]!
   mov   x3, #0x0                      // #0
   mov   x29, sp
   stp   x19, x20, [sp, #16]
   stp   x21, x22, [sp, #32]
   stp   x23, x24, [sp, #48]
sha256_transform_18:
   ldrb  w5, [x1, #1]
   add   x1, x1, #0x4
   ldurb w4, [x1, #-4]
   ldurb w2, [x1, #-2]
   ldurb w6, [x1, #-1]
   lsl   w5, w5, #16
   orr   w2, w6, w2, lsl #8
   orr   w4, w5, w4, lsl #24
   orr   w2, w4, w2
   add   x4, x29, #0x40
   str   w2, [x4, x3]
   add   x3, x3, #0x4
   cmp   x3, #0x40
   b.ne  sha256_transform_18  // b.any
   mov   x1, x4
   add   x7, x4, #0xc0
sha256_transform_58:
   ldp   w3, w2, [x1]
   add   x1, x1, #0x4
   ldr   w4, [x1, #52]
   ldr   w5, [x1, #32]
   cmp   x7, x1
   add   w3, w5, w3
   ror   w5, w2, #18
   ror   w6, w4, #19
   eor   w5, w5, w2, ror #7
   eor   w6, w6, w4, ror #17
   eor   w2, w5, w2, lsr #3
   eor   w4, w6, w4, lsr #10
   add   w2, w4, w2
   add   w2, w2, w3
   str   w2, [x1, #60]
   b.ne  sha256_transform_58  // b.any
   ldp   w21, w20, [x0, #80]
   mov   w23, #0x2f98                  // #12184
   ldp   w19, w30, [x0, #88]
   mov   x8, #0x0                      // #0
   ldp   w18, w17, [x0, #96]
   movk  w23, #0x428a, lsl #16
   ldp   w16, w15, [x0, #104]
   mov   w13, w30 

   mov x12, x30
   bl post_rodata_table
rodata_table:
.byte 0x98, 0x2F, 0x8A, 0x42, 0x91, 0x44, 0x37, 0x71, 0xCF, 0xFB, 0xC0, 0xB5, 0xA5, 0xDB, 0xB5, 0xE9
.byte 0x5B, 0xC2, 0x56, 0x39, 0xF1, 0x11, 0xF1, 0x59, 0xA4, 0x82, 0x3F, 0x92, 0xD5, 0x5E, 0x1C, 0xAB
.byte 0x98, 0xAA, 0x07, 0xD8, 0x01, 0x5B, 0x83, 0x12, 0xBE, 0x85, 0x31, 0x24, 0xC3, 0x7D, 0x0C, 0x55
.byte 0x74, 0x5D, 0xBE, 0x72, 0xFE, 0xB1, 0xDE, 0x80, 0xA7, 0x06, 0xDC, 0x9B, 0x74, 0xF1, 0x9B, 0xC1
.byte 0xC1, 0x69, 0x9B, 0xE4, 0x86, 0x47, 0xBE, 0xEF, 0xC6, 0x9D, 0xC1, 0x0F, 0xCC, 0xA1, 0x0C, 0x24
.byte 0x6F, 0x2C, 0xE9, 0x2D, 0xAA, 0x84, 0x74, 0x4A, 0xDC, 0xA9, 0xB0, 0x5C, 0xDA, 0x88, 0xF9, 0x76
.byte 0x52, 0x51, 0x3E, 0x98, 0x6D, 0xC6, 0x31, 0xA8, 0xC8, 0x27, 0x03, 0xB0, 0xC7, 0x7F, 0x59, 0xBF
.byte 0xF3, 0x0B, 0xE0, 0xC6, 0x47, 0x91, 0xA7, 0xD5, 0x51, 0x63, 0xCA, 0x06, 0x67, 0x29, 0x29, 0x14
.byte 0x85, 0x0A, 0xB7, 0x27, 0x38, 0x21, 0x1B, 0x2E, 0xFC, 0x6D, 0x2C, 0x4D, 0x13, 0x0D, 0x38, 0x53
.byte 0x54, 0x73, 0x0A, 0x65, 0xBB, 0x0A, 0x6A, 0x76, 0x2E, 0xC9, 0xC2, 0x81, 0x85, 0x2C, 0x72, 0x92
.byte 0xA1, 0xE8, 0xBF, 0xA2, 0x4B, 0x66, 0x1A, 0xA8, 0x70, 0x8B, 0x4B, 0xC2, 0xA3, 0x51, 0x6C, 0xC7
.byte 0x19, 0xE8, 0x92, 0xD1, 0x24, 0x06, 0x99, 0xD6, 0x85, 0x35, 0x0E, 0xF4, 0x70, 0xA0, 0x6A, 0x10
.byte 0x16, 0xC1, 0xA4, 0x19, 0x08, 0x6C, 0x37, 0x1E, 0x4C, 0x77, 0x48, 0x27, 0xB5, 0xBC, 0xB0, 0x34
.byte 0xB3, 0x0C, 0x1C, 0x39, 0x4A, 0xAA, 0xD8, 0x4E, 0x4F, 0xCA, 0x9C, 0x5B, 0xF3, 0x6F, 0x2E, 0x68
.byte 0xEE, 0x82, 0x8F, 0x74, 0x6F, 0x63, 0xA5, 0x78, 0x14, 0x78, 0xC8, 0x84, 0x08, 0x02, 0xC7, 0x8C
.byte 0xFA, 0xFF, 0xBE, 0x90, 0xEB, 0x6C, 0x50, 0xA4, 0xF7, 0xA3, 0xF9, 0xBE, 0xF2, 0x78, 0x71, 0xC6
post_rodata_table:
   mov x14, x30
   mov x30, x12

   mov   w12, w17
   mov   w5, w18
   mov   w9, w19
   mov   w24, w15
   mov   w11, w16
   mov   w10, w20
   mov   w6, w21
   b  sha256_transform_104
   nop
sha256_transform_e0:
   ldr   w23, [x8, x14]
   mov   w24, w11
   mov   w13, w9
   mov   w11, w12
   mov   w9, w10
   mov   w12, w5
   mov   w10, w6
   mov   w5, w2
   mov   w6, w1
sha256_transform_104:
   ror   w4, w5, #11
   add   x22, x29, #0x40
   ror   w2, w6, #13
   bic   w1, w11, w5
   eor   w4, w4, w5, ror #6
   and   w3, w5, w12
   ldr   w22, [x22, x8]
   eor   w3, w1, w3
   eor   w7, w9, w10
   eor   w2, w2, w6, ror #2
   eor   w4, w4, w5, ror #25
   add   x8, x8, #0x4
   add   w23, w24, w23
   and   w1, w10, w9
   and   w7, w7, w6
   add   w3, w4, w3
   cmp   x8, #0x100
   eor   w2, w2, w6, ror #22
   add   w3, w3, w23
   eor   w1, w7, w1
   add   w22, w3, w22
   add   w1, w2, w1
   add   w1, w22, w1
   add   w2, w22, w13
   b.ne  sha256_transform_e0  // b.any
   add   w1, w21, w1
   add   w6, w20, w6
   add   w10, w19, w10
   add   w9, w30, w9
   add   w2, w18, w2
   add   w5, w17, w5
   add   w12, w16, w12
   add   w11, w15, w11
   stp   w1, w6, [x0, #80]
   stp   w10, w9, [x0, #88]
   stp   w2, w5, [x0, #96]
   stp   w12, w11, [x0, #104]
   ldp   x19, x20, [sp, #16]
   ldp   x21, x22, [sp, #32]
   ldp   x23, x24, [sp, #48]
   ldp   x29, x30, [sp], #320
   ret
   nop

data_confucion_part_0:
   mov   x4, x1
   mov   x3, #0x0                      // #0
data_confucion_part_0_8:
   ldrb  w5, [x4, #1]
   add   x8, x1, x3
   ldrb  w7, [x4, #2]
   add   x4, x4, #0x3
   ldurb w2, [x4, #-3]
   ldrb  w6, [x0, x3]
   and   w9, w5, w7
   eor   w5, w7, w5
   add   x3, x3, #0x1
   eor   w6, w9, w6
   and   w2, w5, w2
   eor   w2, w6, w2
   cmp   x3, #0x4
   strb  w2, [x8, #12]
   b.ne  data_confucion_part_0_8  // b.any
   ret

hmac_sha256_constprop_1:
   stp   x29, x30, [sp, #-160]!
   mov   w3, #0xe667                   // #58983
   mov   w2, #0xae85                   // #44677
   movk  w3, #0x6a09, lsl #16
   mov   x29, sp
   str   x21, [sp, #32]
   mov   x21, x0
   stp   x19, x20, [sp, #16]
   movk  w2, #0xbb67, lsl #16
   mov   x20, x21
   mov   w7, #0xf372                   // #62322
   stp   w3, w2, [x29, #128]
   mov   w6, #0xf53a                   // #62778
   mov   w5, #0x527f                   // #21119
   mov   w4, #0x688c                   // #26764
   mov   w3, #0xd9ab                   // #55723
   mov   w2, #0xcd19                   // #52505
   movk  w7, #0x3c6e, lsl #16
   movk  w6, #0xa54f, lsl #16
   movk  w5, #0x510e, lsl #16
   movk  w4, #0x9b05, lsl #16
   mov   x19, x1
   movk  w3, #0x1f83, lsl #16
   movk  w2, #0x5be0, lsl #16
   mov   w0, #0x1                      // #1
   ldrb  w1, [x20], #1
   add   x21, x21, #0x4
   str   xzr, [x29, #120]
   stp   w7, w6, [x29, #136]
   stp   w5, w4, [x29, #144]
   stp   w3, w2, [x29, #152]
   strb  w1, [x29, #48]
   str   w0, [x29, #112]
hmac_sha256_constprop_1_84:
   cmp   x21, x20
   sub   x1, x29, #0xf60
   add   x1, x1, w0, uxtw
   b.eq  hmac_sha256_constprop_1_e0  // b.none
hmac_sha256_constprop_1_94:
   ldrb  w2, [x20]
   add   w0, w0, #0x1
   cmp   w0, #0x40
   str   w0, [x29, #112]
   strb  w2, [x1, #3984]
   add   x20, x20, #0x1
   b.ne  hmac_sha256_constprop_1_84  // b.any
   add   x1, x29, #0x30
   mov   x0, x1
   bl sha256_transform
   str   wzr, [x29, #112]
   ldr   x1, [x29, #120]
   cmp   x21, x20
   mov   w0, #0x0                      // #0
   add   x1, x1, #0x200
   str   x1, [x29, #120]
   sub   x1, x29, #0xf60
   add   x1, x1, w0, uxtw
hmac_sha256_constprop_1_e0:
   b.ne  hmac_sha256_constprop_1_94  // b.any
   cmp   w0, #0x37
   sub   x1, x29, #0xf60
   b.ls  hmac_sha256_constprop_1_220  // b.plast
   add   x1, x1, w0, uxtw
   mov   w2, #0xffffff80               // #-128
   add   w0, w0, #0x1
   cmp   w0, #0x3f
   strb  w2, [x1, #3984]
   b.hi  hmac_sha256_constprop_1_11c  // b.pmore
hmac_sha256_constprop_1_104:
   sub   x1, x29, #0xf60
   add   x1, x1, w0, uxtw
   add   w0, w0, #0x1
   cmp   w0, #0x40
   strb  wzr, [x1, #3984]
   b.ne  hmac_sha256_constprop_1_104  // b.any
hmac_sha256_constprop_1_11c:
   add   x1, x29, #0x30
   mov   x0, x1
   bl sha256_transform
   stp   xzr, xzr, [x29, #48]
   ldr   w0, [x29, #112]
   stp   xzr, xzr, [x29, #64]
   stp   xzr, xzr, [x29, #80]
   str   xzr, [x29, #96]
hmac_sha256_constprop_1_13c:
   ldr   x3, [x29, #120]
   ubfiz x2, x0, #3, #29
   add   x1, x29, #0x30
   add   x2, x2, x3
   mov   x0, x1
   strb  w2, [x29, #111]
   str   x2, [x29, #120]
   lsr   x8, x2, #8
   lsr   x7, x2, #16
   lsr   x6, x2, #24
   lsr   x5, x2, #32
   lsr   x4, x2, #40
   lsr   x3, x2, #48
   lsr   x2, x2, #56
   strb  w8, [x29, #110]
   strb  w7, [x29, #109]
   strb  w6, [x29, #108]
   strb  w5, [x29, #107]
   strb  w4, [x29, #106]
   strb  w3, [x29, #105]
   strb  w2, [x29, #104]
   bl sha256_transform
   mov   x1, x19
   mov   w0, #0x18                     // #24
hmac_sha256_constprop_1_19c:
   ldp   w2, w3, [x29, #128]
   add   x1, x1, #0x1
   lsr   w2, w2, w0
   lsr   w3, w3, w0
   sturb w2, [x1, #-1]
   strb  w3, [x1, #3]
   ldr   w2, [x29, #136]
   lsr   w2, w2, w0
   strb  w2, [x1, #7]
   ldr   w2, [x29, #140]
   lsr   w2, w2, w0
   strb  w2, [x1, #11]
   ldr   w2, [x29, #144]
   lsr   w2, w2, w0
   strb  w2, [x1, #15]
   ldr   w2, [x29, #148]
   lsr   w2, w2, w0
   strb  w2, [x1, #19]
   ldr   w2, [x29, #152]
   lsr   w2, w2, w0
   strb  w2, [x1, #23]
   ldr   w2, [x29, #156]
   lsr   w2, w2, w0
   sub   w0, w0, #0x8
   cmn   w0, #0x8
   strb  w2, [x1, #27]
   b.ne  hmac_sha256_constprop_1_19c  // b.any
   ldp   x19, x20, [sp, #16]
   mov   w0, #0x0                      // #0
   ldr   x21, [sp, #32]
   ldp   x29, x30, [sp], #160
   ret
   nop
hmac_sha256_constprop_1_220:
   add   x2, x1, w0, uxtw
   mov   w3, #0xffffff80               // #-128
   add   w1, w0, #0x1
   cmp   w1, #0x38
   strb  w3, [x2, #3984]
   b.eq  hmac_sha256_constprop_1_13c  // b.none
hmac_sha256_constprop_1_238:
   sub   x2, x29, #0xf60
   add   x2, x2, w1, uxtw
   add   w1, w1, #0x1
   cmp   w1, #0x38
   strb  wzr, [x2, #3984]
   b.eq  hmac_sha256_constprop_1_13c  // b.none
   sub   x2, x29, #0xf60
   add   x2, x2, w1, uxtw
   add   w1, w1, #0x1
   cmp   w1, #0x38
   strb  wzr, [x2, #3984]
   b.ne  hmac_sha256_constprop_1_238  // b.any
   b  hmac_sha256_constprop_1_13c
   nop

data_confucion:
   stp   x29, x30, [sp, #-128]!
   mov   x29, sp
   stp   x19, x20, [sp, #16]
   add   x19, x29, #0x38
   str   x21, [sp, #32]
   mov   x21, x1
   mov   x1, x19
   mov   x20, x0
   bl hmac_sha256_constprop_1
   mov   w10, w0
   cbnz  w0, data_confucion_94
   add   x0, x29, #0x58
   mov   x1, #0x0                      // #0
   mov   x2, x0
data_confucion_38:
   add   x2, x2, #0x9
   ldr   x4, [x19, x1, lsl #3]
   ldrb  w3, [x20, x1]
   add   x1, x1, #0x1
   cmp   x1, #0x4
   sturb w3, [x2, #-1]
   stur  x4, [x2, #-9]
   b.ne  data_confucion_38  // b.any
   mov   x4, x21
   add   x5, x29, #0x7c
data_confucion_60:
   ldrb  w3, [x0]
   add   x0, x0, #0x3
   ldurb w2, [x0, #-1]
   ldurb w1, [x0, #-2]
   cmp   x5, x0
   bic   w2, w2, w3
   and   w1, w3, w1
   eor   w1, w2, w1
   strb  w1, [x4], #1
   b.ne  data_confucion_60  // b.any
   mov   x1, x21
   mov   x0, x20
   bl data_confucion_part_0
data_confucion_94:
   ldp   x19, x20, [sp, #16]
   mov   w0, w10
   ldr   x21, [sp, #32]
   ldp   x29, x30, [sp], #128
   ret

data_encrypt:
   stp   x29, x30, [sp, #-144]!
   mov   x29, sp
   stp   x19, x20, [sp, #16]
   add   x19, x29, #0x48
   mov   x20, x1
   mov   x1, x19
   str   x21, [sp, #32]
   mov   x21, x0
   bl hmac_sha256_constprop_1
   cbnz  w0, data_encrypt_c0
   add   x2, x29, #0x68
   mov   x1, #0x0                      // #0
   mov   x3, x2
data_encrypt_34:
   add   x3, x3, #0x9
   ldr   x5, [x19, x1, lsl #3]
   ldrb  w4, [x21, x1]
   add   x1, x1, #0x1
   cmp   x1, #0x4
   sturb w4, [x3, #-1]
   stur  x5, [x3, #-9]
   b.ne  data_encrypt_34  // b.any
   add   x6, x29, #0x38
   mov   x3, #0x0                      // #0
data_encrypt_5c:
   ldrb  w5, [x2, #1]
   add   x2, x2, #0x3
   ldurb w1, [x2, #-1]
   ldurb w4, [x2, #-3]
   eor   w7, w1, w5
   and   w1, w5, w1
   and   w4, w7, w4
   eor   w1, w4, w1
   strb  w1, [x6, x3]
   add   x3, x3, #0x1
   cmp   x3, #0xc
   b.ne  data_encrypt_5c  // b.any
   mov   x1, x6
   mov   x3, #0x0                      // #0
data_encrypt_94:
   ldrb  w5, [x1]
   add   x1, x1, #0x3
   ldurb w4, [x1, #-1]
   ldurb w2, [x1, #-2]
   bic   w4, w4, w5
   and   w2, w5, w2
   eor   w2, w4, w2
   strb  w2, [x20, x3]
   add   x3, x3, #0x1
   cmp   x3, #0x4
   b.ne  data_encrypt_94  // b.any
data_encrypt_c0:
   ldp   x19, x20, [sp, #16]
   ldr   x21, [sp, #32]
   ldp   x29, x30, [sp], #144
   ret

wcn_bind_verify_calculate_verify_data:
   stp   x29, x30, [sp, #-96]!
   mov   x29, sp
   stp   x19, x20, [sp, #16]
   mov   x20, x0
   str   x21, [sp, #32]
   add   x0, x29, #0x40
   stp   xzr, xzr, [x1]
   mov   x19, x1
   // bl marlin_get_wcn_chipid
   //cbz   w0, wcn_bind_verify_calculate_verify_data_38
   b wcn_bind_verify_calculate_verify_data_38
wcn_bind_verify_calculate_verify_data_28:
   ldp   x19, x20, [sp, #16]
   ldr   x21, [sp, #32]
   ldp   x29, x30, [sp], #96
   ret
wcn_bind_verify_calculate_verify_data_38:
   mov   x2, x20
   add   x21, x29, #0x38
   mov   x1, #0x0                      // #0
wcn_bind_verify_calculate_verify_data_44:
   add   x4, x20, x1
   ldrb  w3, [x2, #1]
   ldrb  w5, [x2, #2]
   add   x2, x2, #0x3
   ldurb w0, [x2, #-3]
   ldrb  w4, [x4, #12]
   and   w6, w3, w5
   eor   w3, w5, w3
   eor   w4, w6, w4
   and   w0, w3, w0
   eor   w0, w4, w0
   strb  w0, [x21, x1]
   add   x1, x1, #0x1
   cmp   x1, #0x4
   b.ne  wcn_bind_verify_calculate_verify_data_44  // b.any
   mov   x0, x21
   add   x1, x29, #0x50
   bl data_confucion
   cbnz  w0, wcn_bind_verify_calculate_verify_data_28
   add   x1, x29, #0x50
   mov   x0, x20
   mov   x2, #0x10                     // #16
   bl memcmp
   cbnz  w0, wcn_bind_verify_calculate_verify_data_c8
   add   x1, x29, #0x50
   mov   x0, x21
   bl data_encrypt
   cbnz  w0, wcn_bind_verify_calculate_verify_data_28
   mov   x1, x19
   add   x0, x29, #0x50
   bl data_confucion
   b  wcn_bind_verify_calculate_verify_data_28
   nop
wcn_bind_verify_calculate_verify_data_c8:
   mov   w0, #0x1                      // #1
   b  wcn_bind_verify_calculate_verify_data_28

// .section .rodata
// rodata_table:
// .byte 0x98, 0x2F, 0x8A, 0x42, 0x91, 0x44, 0x37, 0x71, 0xCF, 0xFB, 0xC0, 0xB5, 0xA5, 0xDB, 0xB5, 0xE9
// .byte 0x5B, 0xC2, 0x56, 0x39, 0xF1, 0x11, 0xF1, 0x59, 0xA4, 0x82, 0x3F, 0x92, 0xD5, 0x5E, 0x1C, 0xAB
// .byte 0x98, 0xAA, 0x07, 0xD8, 0x01, 0x5B, 0x83, 0x12, 0xBE, 0x85, 0x31, 0x24, 0xC3, 0x7D, 0x0C, 0x55
// .byte 0x74, 0x5D, 0xBE, 0x72, 0xFE, 0xB1, 0xDE, 0x80, 0xA7, 0x06, 0xDC, 0x9B, 0x74, 0xF1, 0x9B, 0xC1
// .byte 0xC1, 0x69, 0x9B, 0xE4, 0x86, 0x47, 0xBE, 0xEF, 0xC6, 0x9D, 0xC1, 0x0F, 0xCC, 0xA1, 0x0C, 0x24
// .byte 0x6F, 0x2C, 0xE9, 0x2D, 0xAA, 0x84, 0x74, 0x4A, 0xDC, 0xA9, 0xB0, 0x5C, 0xDA, 0x88, 0xF9, 0x76
// .byte 0x52, 0x51, 0x3E, 0x98, 0x6D, 0xC6, 0x31, 0xA8, 0xC8, 0x27, 0x03, 0xB0, 0xC7, 0x7F, 0x59, 0xBF
// .byte 0xF3, 0x0B, 0xE0, 0xC6, 0x47, 0x91, 0xA7, 0xD5, 0x51, 0x63, 0xCA, 0x06, 0x67, 0x29, 0x29, 0x14
// .byte 0x85, 0x0A, 0xB7, 0x27, 0x38, 0x21, 0x1B, 0x2E, 0xFC, 0x6D, 0x2C, 0x4D, 0x13, 0x0D, 0x38, 0x53
// .byte 0x54, 0x73, 0x0A, 0x65, 0xBB, 0x0A, 0x6A, 0x76, 0x2E, 0xC9, 0xC2, 0x81, 0x85, 0x2C, 0x72, 0x92
// .byte 0xA1, 0xE8, 0xBF, 0xA2, 0x4B, 0x66, 0x1A, 0xA8, 0x70, 0x8B, 0x4B, 0xC2, 0xA3, 0x51, 0x6C, 0xC7
// .byte 0x19, 0xE8, 0x92, 0xD1, 0x24, 0x06, 0x99, 0xD6, 0x85, 0x35, 0x0E, 0xF4, 0x70, 0xA0, 0x6A, 0x10
// .byte 0x16, 0xC1, 0xA4, 0x19, 0x08, 0x6C, 0x37, 0x1E, 0x4C, 0x77, 0x48, 0x27, 0xB5, 0xBC, 0xB0, 0x34
// .byte 0xB3, 0x0C, 0x1C, 0x39, 0x4A, 0xAA, 0xD8, 0x4E, 0x4F, 0xCA, 0x9C, 0x5B, 0xF3, 0x6F, 0x2E, 0x68
// .byte 0xEE, 0x82, 0x8F, 0x74, 0x6F, 0x63, 0xA5, 0x78, 0x14, 0x78, 0xC8, 0x84, 0x08, 0x02, 0xC7, 0x8C
// .byte 0xFA, 0xFF, 0xBE, 0x90, 0xEB, 0x6C, 0x50, 0xA4, 0xF7, 0xA3, 0xF9, 0xBE, 0xF2, 0x78, 0x71, 0xC6
