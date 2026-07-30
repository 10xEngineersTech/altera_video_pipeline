// (C) 2001-2025 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.




`timescale 1ps/1ps

module compare_eq #(
    parameter WIDTH=10
) (
    input [WIDTH-1:0]  in_a,
    input [WIDTH-1:0]  in_b,
    output             equal
);

assign equal = (in_a==in_b);

endmodule 
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "3wrV9vxkV6cm3KZuU0YmrpECz0gO85cpwPAwvoDmqQfm97s5UZmfYguhz8/428PUc52yhrNL2DIcflQpOkDgIHixsN/qQIr1Yl8RrFxWUW9+BWG4mgSfzo8rnvUQWJayS2cUu9k11ZYcmdN3LHF6s1KoNJ9JXlORxyEgsglhkdhkf1ALusfEVuG233HcW8M7RNXR6hb8GxDqWtwlLRj1qCOttHqbLRcgsbfjrMDR1FjQL9exbfXYTp137Dtd6Y0g6L4MgYOzwjRQpR0jP8MXyY0JHzOEOLBvGLeAfT0zJFN5eB54bfkyPWJXaUD9Yt++782v+rIWyQg5F3Q+VN5KWZObQSZSJZjskCikMATWs4odQUY2/UcTZ3iS0cyZ1gXZBv5vGyXsGpo3JMt8UqBRfF1GddwcaSNOLRFHi1adCsXu76Z1F1CAuiXCV+d92LcX5yDP9SbxTbuY8uOetEv1wHnVth16O1avdtiqUj8qtb0rrDaBUiskNDQOGgJrkP3YC2PV5p5Ep5C4udKdywI3ziips38Ds90PuJy67yjR8tG/R6zabBtu54dn1e8SLL326vGTA2sisJaEzjaRfIKsLJnA326qDRFJRXuJyNTM7cWuc6AbVd7frqsYkl08yfw34RPfW1+c+YH4f3PlPLrR0O6uYYvNhwJ9mQUj23tFchjYyASeMky7PNT0BIRTQEikjAtaLzBKpg5fs5fbnOqOERLQBFzbBPh4+FDq/9hu4gCx7eTa7MyIsxZKV5gt/lwT2hZcqDd/Z33loBENj5mAY5TuV7o5T6CQNg04nejD9dHDDPGwYJWtrjyx7Cdd/NXGCkPee8GzhdSawScqvEdT4qSIxEZ5C/Yaco4E3KjR+kltA956dS76He9dUzKofYAjSx8SNrd00sOxpHpDnq0yCOcmq6U2usnwNpYR4/6dZvcbsyarjLzWAiNvHJzbqrGMYbPHq2pU03yyDXkLFcSkzzETYMcG+/Jb0ZL6RUUP88PAn1MYWRVdlTzrc4hYcISV"
`endif
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "BcKhm8GW0cpHsCa4G/ETpFMsNr62fM+PAUz29Ycpfq3jc/bjNAE5EdpSN6IBYxdzX1TKn5XwmNZpIHq28ZhR8dtiYA3JujkQLepHEAgPb4kI6FhViBdLuWHMO+FW9WwumWeRl6HJXydjQcpk2O8zckSO4/l0Q8bbWSMGG55kEQZjTFXnv4ItQaDgViLzFKr53eXF141vDcnhom3sW4rJ3L/w/vvROJj0pZK07t2TgwJKV0ZUALD8teKRfouUvnwhDDPIDZXaoEq3ESq7/e2bSCpQYAs0JwDqpSnaEGotuzsMO0XC/lWORMBNPqv5Kn0pvgPDOExzH+QE/aTXhwrVAE6T6hxfWeye4FBuBvsjFEMNd7quD+QPK3eT37MS1p/wHaRZ15AnZlmETeKwbBq+fSoKiZO898ZbgofNOmiE4XqlECV9tC+77Xu7D0DAlm8EAYwkiABcaiRCr4cBElqMwnDZrdEGS7ToImtzEs9NEkRmn/sPbhXJ0YJKa9ykx40gH5A5Tg06uPIzDu2Niu32J3GerKzAK3zf61UN8DsjhvDkEzq23GC8fbEIcwb9AqEaXcSqOh/4bA4p2WF4nGck7LRlbIHg/s3j8PmgUaU+9ALSMWUSF6mLx4SZ2DHyCJU3DkMT9PaIT/FBXuqy4AcMmnbbTAykQJGi6L8sfSaZo9bW7DqNgX8R2kGoX18PiedrQrS+bm11futsj21wLDNDLjb7SMqQ/VLKVUab0xnom7OCxHRyH5vKc5aLqaCoMbt1n+EckZqtkrkU8sxuVMcTTd8LHFrtNG8DJJEmys1SuBeF86qWStLU2JlcC1mbgPoDZCCfZ+PBIu38odel9MhaOra7C6lufNWVqFVkyxEKFPc+WBFwbNEVtdeEGdRGbqU07IOBSpHYFbD89lUedRMLN4aZ6XtdwXiSG4ZQAQ2ZGRAs9FChOrC/TRlp7b3rfgrLuu0Cy/L8AKCW/zYyt3JsPtCAamAJpQRYP2tR4Emo1+2YQAgj7j29QRVCpfAr556M"
`endif