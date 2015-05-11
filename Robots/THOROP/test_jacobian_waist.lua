local function jac(q)
local c1, s1 = cos(q[1]), sin(q[1])
local c2, s2 = cos(q[2]), sin(q[2])
local c3, s3 = cos(q[3]), sin(q[3])
local c4, s4 = cos(q[4]), sin(q[4])
local c5, s5 = cos(q[5]), sin(q[5])
local c6, s6 = cos(q[6]), sin(q[6])
local c7, s7 = cos(q[7]), sin(q[7])
local c8, s8 = cos(q[8]), sin(q[8])
return
{
{elbowOffsetX*((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5) - elbowOffsetX*(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4) - l_8x*(((((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*s6 + ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*c6)*c7 - (-(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*s5 + (s1*c2*c3 + s3*c1)*c5)*s7)*c8 + (((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*c6 - ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*s6)*s8) - l_8y*(-((((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*s6 + ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*c6)*c7 - (-(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*s5 + (s1*c2*c3 + s3*c1)*c5)*s7)*s8 + (((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*c6 - ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*s6)*c8) - l_8z*((((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*s6 + ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*c6)*s7 + (-(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*s5 + (s1*c2*c3 + s3*c1)*c5)*c7) - lowerArmLength*(-(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*s5 + (s1*c2*c3 + s3*c1)*c5) - shoulderOffsetY*c1 + upperArmLength*(-s1*c2*c3 - s3*c1),
 -(-l_8x*(((((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*s6 + (s2*s3*c4 + s4*c2)*c6)*c7 - (-(-s2*s3*s4 + c2*c4)*s5 - s2*c3*c5)*s7)*c8 + (((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*c6 - (s2*s3*c4 + s4*c2)*s6)*s8) - l_8y*(-((((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*s6 + (s2*s3*c4 + s4*c2)*c6)*c7 - (-(-s2*s3*s4 + c2*c4)*s5 - s2*c3*c5)*s7)*s8 + (((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*c6 - (s2*s3*c4 + s4*c2)*s6)*c8) - l_8z*((((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*s6 + (s2*s3*c4 + s4*c2)*c6)*s7 + (-(-s2*s3*s4 + c2*c4)*s5 - s2*c3*c5)*c7))*c1 + (-elbowOffsetX*((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3) + elbowOffsetX*(-s2*s3*s4 + c2*c4) + lowerArmLength*(-(-s2*s3*s4 + c2*c4)*s5 - s2*c3*c5) - upperArmLength*s2*c3)*c1,
 -(l_8x*(((((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*s6 + ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*c6)*c7 - (-(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*s5 + (s1*c2*c3 + s3*c1)*c5)*s7)*c8 + (((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*c6 - ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*s6)*s8) + l_8y*(-((((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*s6 + ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*c6)*c7 - (-(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*s5 + (s1*c2*c3 + s3*c1)*c5)*s7)*s8 + (((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*c6 - ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*s6)*c8) + l_8z*((((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*s6 + ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*c6)*s7 + (-(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*s5 + (s1*c2*c3 + s3*c1)*c5)*c7))*c2 - (-l_8x*(((((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*s6 + (s2*s3*c4 + s4*c2)*c6)*c7 - (-(-s2*s3*s4 + c2*c4)*s5 - s2*c3*c5)*s7)*c8 + (((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*c6 - (s2*s3*c4 + s4*c2)*s6)*s8) - l_8y*(-((((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*s6 + (s2*s3*c4 + s4*c2)*c6)*c7 - (-(-s2*s3*s4 + c2*c4)*s5 - s2*c3*c5)*s7)*s8 + (((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*c6 - (s2*s3*c4 + s4*c2)*s6)*c8) - l_8z*((((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*s6 + (s2*s3*c4 + s4*c2)*c6)*s7 + (-(-s2*s3*s4 + c2*c4)*s5 - s2*c3*c5)*c7))*s1*s2 - (-elbowOffsetX*((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5) + elbowOffsetX*(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4) + lowerArmLength*(-(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*s5 + (s1*c2*c3 + s3*c1)*c5) - upperArmLength*(-s1*c2*c3 - s3*c1))*c2 + (-elbowOffsetX*((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3) + elbowOffsetX*(-s2*s3*s4 + c2*c4) + lowerArmLength*(-(-s2*s3*s4 + c2*c4)*s5 - s2*c3*c5) - upperArmLength*s2*c3)*s1*s2,
 (s1*c2*c3 + s3*c1)*(-elbowOffsetX*((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3) + elbowOffsetX*(-s2*s3*s4 + c2*c4) + lowerArmLength*(-(-s2*s3*s4 + c2*c4)*s5 - s2*c3*c5)) - (s1*c2*c3 + s3*c1)*(-l_8x*(((((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*s6 + (s2*s3*c4 + s4*c2)*c6)*c7 - (-(-s2*s3*s4 + c2*c4)*s5 - s2*c3*c5)*s7)*c8 + (((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*c6 - (s2*s3*c4 + s4*c2)*s6)*s8) - l_8y*(-((((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*s6 + (s2*s3*c4 + s4*c2)*c6)*c7 - (-(-s2*s3*s4 + c2*c4)*s5 - s2*c3*c5)*s7)*s8 + (((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*c6 - (s2*s3*c4 + s4*c2)*s6)*c8) - l_8z*((((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*s6 + (s2*s3*c4 + s4*c2)*c6)*s7 + (-(-s2*s3*s4 + c2*c4)*s5 - s2*c3*c5)*c7)) + (-elbowOffsetX*((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5) + elbowOffsetX*(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4) + lowerArmLength*(-(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*s5 + (s1*c2*c3 + s3*c1)*c5))*s2*c3 + (l_8x*(((((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*s6 + ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*c6)*c7 - (-(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*s5 + (s1*c2*c3 + s3*c1)*c5)*s7)*c8 + (((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*c6 - ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*s6)*s8) + l_8y*(-((((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*s6 + ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*c6)*c7 - (-(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*s5 + (s1*c2*c3 + s3*c1)*c5)*s7)*s8 + (((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*c6 - ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*s6)*c8) + l_8z*((((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*s6 + ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*c6)*s7 + (-(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*s5 + (s1*c2*c3 + s3*c1)*c5)*c7))*s2*c3,
 -(-elbowOffsetX*((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5) + lowerArmLength*(-(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*s5 + (s1*c2*c3 + s3*c1)*c5))*(s2*s3*c4 + s4*c2) + (-elbowOffsetX*((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3) + lowerArmLength*(-(-s2*s3*s4 + c2*c4)*s5 - s2*c3*c5))*((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4) - ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*(-l_8x*(((((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*s6 + (s2*s3*c4 + s4*c2)*c6)*c7 - (-(-s2*s3*s4 + c2*c4)*s5 - s2*c3*c5)*s7)*c8 + (((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*c6 - (s2*s3*c4 + s4*c2)*s6)*s8) - l_8y*(-((((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*s6 + (s2*s3*c4 + s4*c2)*c6)*c7 - (-(-s2*s3*s4 + c2*c4)*s5 - s2*c3*c5)*s7)*s8 + (((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*c6 - (s2*s3*c4 + s4*c2)*s6)*c8) - l_8z*((((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*s6 + (s2*s3*c4 + s4*c2)*c6)*s7 + (-(-s2*s3*s4 + c2*c4)*s5 - s2*c3*c5)*c7)) - (s2*s3*c4 + s4*c2)*(l_8x*(((((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*s6 + ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*c6)*c7 - (-(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*s5 + (s1*c2*c3 + s3*c1)*c5)*s7)*c8 + (((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*c6 - ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*s6)*s8) + l_8y*(-((((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*s6 + ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*c6)*c7 - (-(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*s5 + (s1*c2*c3 + s3*c1)*c5)*s7)*s8 + (((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*c6 - ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*s6)*c8) + l_8z*((((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*s6 + ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*c6)*s7 + (-(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*s5 + (s1*c2*c3 + s3*c1)*c5)*c7)),
 -(-(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*s5 + (s1*c2*c3 + s3*c1)*c5)*(-l_8x*(((((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*s6 + (s2*s3*c4 + s4*c2)*c6)*c7 - (-(-s2*s3*s4 + c2*c4)*s5 - s2*c3*c5)*s7)*c8 + (((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*c6 - (s2*s3*c4 + s4*c2)*s6)*s8) - l_8y*(-((((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*s6 + (s2*s3*c4 + s4*c2)*c6)*c7 - (-(-s2*s3*s4 + c2*c4)*s5 - s2*c3*c5)*s7)*s8 + (((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*c6 - (s2*s3*c4 + s4*c2)*s6)*c8) - l_8z*((((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*s6 + (s2*s3*c4 + s4*c2)*c6)*s7 + (-(-s2*s3*s4 + c2*c4)*s5 - s2*c3*c5)*c7)) - (-(-s2*s3*s4 + c2*c4)*s5 - s2*c3*c5)*(l_8x*(((((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*s6 + ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*c6)*c7 - (-(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*s5 + (s1*c2*c3 + s3*c1)*c5)*s7)*c8 + (((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*c6 - ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*s6)*s8) + l_8y*(-((((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*s6 + ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*c6)*c7 - (-(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*s5 + (s1*c2*c3 + s3*c1)*c5)*s7)*s8 + (((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*c6 - ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*s6)*c8) + l_8z*((((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*s6 + ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*c6)*s7 + (-(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*s5 + (s1*c2*c3 + s3*c1)*c5)*c7)),
 -(((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*c6 - ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*s6)*(-l_8x*(((((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*s6 + (s2*s3*c4 + s4*c2)*c6)*c7 - (-(-s2*s3*s4 + c2*c4)*s5 - s2*c3*c5)*s7)*c8 + (((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*c6 - (s2*s3*c4 + s4*c2)*s6)*s8) - l_8y*(-((((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*s6 + (s2*s3*c4 + s4*c2)*c6)*c7 - (-(-s2*s3*s4 + c2*c4)*s5 - s2*c3*c5)*s7)*s8 + (((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*c6 - (s2*s3*c4 + s4*c2)*s6)*c8) - l_8z*((((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*s6 + (s2*s3*c4 + s4*c2)*c6)*s7 + (-(-s2*s3*s4 + c2*c4)*s5 - s2*c3*c5)*c7)) - (((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*c6 - (s2*s3*c4 + s4*c2)*s6)*(l_8x*(((((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*s6 + ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*c6)*c7 - (-(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*s5 + (s1*c2*c3 + s3*c1)*c5)*s7)*c8 + (((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*c6 - ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*s6)*s8) + l_8y*(-((((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*s6 + ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*c6)*c7 - (-(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*s5 + (s1*c2*c3 + s3*c1)*c5)*s7)*s8 + (((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*c6 - ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*s6)*c8) + l_8z*((((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*s6 + ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*c6)*s7 + (-(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*s5 + (s1*c2*c3 + s3*c1)*c5)*c7)),
 -((((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*s6 + ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*c6)*s7 + (-(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*s5 + (s1*c2*c3 + s3*c1)*c5)*c7)*(-l_8x*(((((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*s6 + (s2*s3*c4 + s4*c2)*c6)*c7 - (-(-s2*s3*s4 + c2*c4)*s5 - s2*c3*c5)*s7)*c8 + (((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*c6 - (s2*s3*c4 + s4*c2)*s6)*s8) - l_8y*(-((((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*s6 + (s2*s3*c4 + s4*c2)*c6)*c7 - (-(-s2*s3*s4 + c2*c4)*s5 - s2*c3*c5)*s7)*s8 + (((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*c6 - (s2*s3*c4 + s4*c2)*s6)*c8) - l_8z*((((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*s6 + (s2*s3*c4 + s4*c2)*c6)*s7 + (-(-s2*s3*s4 + c2*c4)*s5 - s2*c3*c5)*c7)) - ((((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*s6 + (s2*s3*c4 + s4*c2)*c6)*s7 + (-(-s2*s3*s4 + c2*c4)*s5 - s2*c3*c5)*c7)*(l_8x*(((((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*s6 + ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*c6)*c7 - (-(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*s5 + (s1*c2*c3 + s3*c1)*c5)*s7)*c8 + (((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*c6 - ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*s6)*s8) + l_8y*(-((((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*s6 + ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*c6)*c7 - (-(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*s5 + (s1*c2*c3 + s3*c1)*c5)*s7)*s8 + (((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*c6 - ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*s6)*c8) + l_8z*((((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*s6 + ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*c6)*s7 + (-(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*s5 + (s1*c2*c3 + s3*c1)*c5)*c7)),

},

{-elbowOffsetX*((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5) + elbowOffsetX*(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4) + l_8x*(((((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*s6 + ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*c6)*c7 - (-(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*s5 + (-s1*s3 + c1*c2*c3)*c5)*s7)*c8 + (((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*c6 - ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*s6)*s8) + l_8y*(-((((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*s6 + ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*c6)*c7 - (-(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*s5 + (-s1*s3 + c1*c2*c3)*c5)*s7)*s8 + (((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*c6 - ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*s6)*c8) + l_8z*((((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*s6 + ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*c6)*s7 + (-(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*s5 + (-s1*s3 + c1*c2*c3)*c5)*c7) + lowerArmLength*(-(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*s5 + (-s1*s3 + c1*c2*c3)*c5) - shoulderOffsetY*s1 - upperArmLength*(s1*s3 - c1*c2*c3),
 (l_8x*(((((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*s6 + (s2*s3*c4 + s4*c2)*c6)*c7 - (-(-s2*s3*s4 + c2*c4)*s5 - s2*c3*c5)*s7)*c8 + (((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*c6 - (s2*s3*c4 + s4*c2)*s6)*s8) + l_8y*(-((((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*s6 + (s2*s3*c4 + s4*c2)*c6)*c7 - (-(-s2*s3*s4 + c2*c4)*s5 - s2*c3*c5)*s7)*s8 + (((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*c6 - (s2*s3*c4 + s4*c2)*s6)*c8) + l_8z*((((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*s6 + (s2*s3*c4 + s4*c2)*c6)*s7 + (-(-s2*s3*s4 + c2*c4)*s5 - s2*c3*c5)*c7))*s1 + (-elbowOffsetX*((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3) + elbowOffsetX*(-s2*s3*s4 + c2*c4) + lowerArmLength*(-(-s2*s3*s4 + c2*c4)*s5 - s2*c3*c5) - upperArmLength*s2*c3)*s1,
 -(-l_8x*(((((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*s6 + ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*c6)*c7 - (-(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*s5 + (-s1*s3 + c1*c2*c3)*c5)*s7)*c8 + (((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*c6 - ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*s6)*s8) - l_8y*(-((((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*s6 + ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*c6)*c7 - (-(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*s5 + (-s1*s3 + c1*c2*c3)*c5)*s7)*s8 + (((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*c6 - ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*s6)*c8) - l_8z*((((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*s6 + ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*c6)*s7 + (-(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*s5 + (-s1*s3 + c1*c2*c3)*c5)*c7))*c2 - (l_8x*(((((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*s6 + (s2*s3*c4 + s4*c2)*c6)*c7 - (-(-s2*s3*s4 + c2*c4)*s5 - s2*c3*c5)*s7)*c8 + (((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*c6 - (s2*s3*c4 + s4*c2)*s6)*s8) + l_8y*(-((((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*s6 + (s2*s3*c4 + s4*c2)*c6)*c7 - (-(-s2*s3*s4 + c2*c4)*s5 - s2*c3*c5)*s7)*s8 + (((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*c6 - (s2*s3*c4 + s4*c2)*s6)*c8) + l_8z*((((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*s6 + (s2*s3*c4 + s4*c2)*c6)*s7 + (-(-s2*s3*s4 + c2*c4)*s5 - s2*c3*c5)*c7))*s2*c1 + (-elbowOffsetX*((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5) + elbowOffsetX*(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4) + lowerArmLength*(-(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*s5 + (-s1*s3 + c1*c2*c3)*c5) - upperArmLength*(s1*s3 - c1*c2*c3))*c2 - (-elbowOffsetX*((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3) + elbowOffsetX*(-s2*s3*s4 + c2*c4) + lowerArmLength*(-(-s2*s3*s4 + c2*c4)*s5 - s2*c3*c5) - upperArmLength*s2*c3)*s2*c1,
 -(-s1*s3 + c1*c2*c3)*(-elbowOffsetX*((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3) + elbowOffsetX*(-s2*s3*s4 + c2*c4) + lowerArmLength*(-(-s2*s3*s4 + c2*c4)*s5 - s2*c3*c5)) - (-s1*s3 + c1*c2*c3)*(l_8x*(((((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*s6 + (s2*s3*c4 + s4*c2)*c6)*c7 - (-(-s2*s3*s4 + c2*c4)*s5 - s2*c3*c5)*s7)*c8 + (((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*c6 - (s2*s3*c4 + s4*c2)*s6)*s8) + l_8y*(-((((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*s6 + (s2*s3*c4 + s4*c2)*c6)*c7 - (-(-s2*s3*s4 + c2*c4)*s5 - s2*c3*c5)*s7)*s8 + (((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*c6 - (s2*s3*c4 + s4*c2)*s6)*c8) + l_8z*((((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*s6 + (s2*s3*c4 + s4*c2)*c6)*s7 + (-(-s2*s3*s4 + c2*c4)*s5 - s2*c3*c5)*c7)) - (-elbowOffsetX*((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5) + elbowOffsetX*(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4) + lowerArmLength*(-(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*s5 + (-s1*s3 + c1*c2*c3)*c5))*s2*c3 + (-l_8x*(((((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*s6 + ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*c6)*c7 - (-(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*s5 + (-s1*s3 + c1*c2*c3)*c5)*s7)*c8 + (((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*c6 - ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*s6)*s8) - l_8y*(-((((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*s6 + ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*c6)*c7 - (-(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*s5 + (-s1*s3 + c1*c2*c3)*c5)*s7)*s8 + (((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*c6 - ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*s6)*c8) - l_8z*((((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*s6 + ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*c6)*s7 + (-(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*s5 + (-s1*s3 + c1*c2*c3)*c5)*c7))*s2*c3,
 (-elbowOffsetX*((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5) + lowerArmLength*(-(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*s5 + (-s1*s3 + c1*c2*c3)*c5))*(s2*s3*c4 + s4*c2) - (-elbowOffsetX*((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3) + lowerArmLength*(-(-s2*s3*s4 + c2*c4)*s5 - s2*c3*c5))*((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1) - ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*(l_8x*(((((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*s6 + (s2*s3*c4 + s4*c2)*c6)*c7 - (-(-s2*s3*s4 + c2*c4)*s5 - s2*c3*c5)*s7)*c8 + (((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*c6 - (s2*s3*c4 + s4*c2)*s6)*s8) + l_8y*(-((((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*s6 + (s2*s3*c4 + s4*c2)*c6)*c7 - (-(-s2*s3*s4 + c2*c4)*s5 - s2*c3*c5)*s7)*s8 + (((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*c6 - (s2*s3*c4 + s4*c2)*s6)*c8) + l_8z*((((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*s6 + (s2*s3*c4 + s4*c2)*c6)*s7 + (-(-s2*s3*s4 + c2*c4)*s5 - s2*c3*c5)*c7)) - (s2*s3*c4 + s4*c2)*(-l_8x*(((((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*s6 + ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*c6)*c7 - (-(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*s5 + (-s1*s3 + c1*c2*c3)*c5)*s7)*c8 + (((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*c6 - ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*s6)*s8) - l_8y*(-((((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*s6 + ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*c6)*c7 - (-(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*s5 + (-s1*s3 + c1*c2*c3)*c5)*s7)*s8 + (((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*c6 - ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*s6)*c8) - l_8z*((((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*s6 + ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*c6)*s7 + (-(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*s5 + (-s1*s3 + c1*c2*c3)*c5)*c7)),
 -(-(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*s5 + (-s1*s3 + c1*c2*c3)*c5)*(l_8x*(((((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*s6 + (s2*s3*c4 + s4*c2)*c6)*c7 - (-(-s2*s3*s4 + c2*c4)*s5 - s2*c3*c5)*s7)*c8 + (((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*c6 - (s2*s3*c4 + s4*c2)*s6)*s8) + l_8y*(-((((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*s6 + (s2*s3*c4 + s4*c2)*c6)*c7 - (-(-s2*s3*s4 + c2*c4)*s5 - s2*c3*c5)*s7)*s8 + (((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*c6 - (s2*s3*c4 + s4*c2)*s6)*c8) + l_8z*((((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*s6 + (s2*s3*c4 + s4*c2)*c6)*s7 + (-(-s2*s3*s4 + c2*c4)*s5 - s2*c3*c5)*c7)) - (-(-s2*s3*s4 + c2*c4)*s5 - s2*c3*c5)*(-l_8x*(((((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*s6 + ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*c6)*c7 - (-(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*s5 + (-s1*s3 + c1*c2*c3)*c5)*s7)*c8 + (((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*c6 - ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*s6)*s8) - l_8y*(-((((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*s6 + ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*c6)*c7 - (-(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*s5 + (-s1*s3 + c1*c2*c3)*c5)*s7)*s8 + (((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*c6 - ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*s6)*c8) - l_8z*((((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*s6 + ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*c6)*s7 + (-(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*s5 + (-s1*s3 + c1*c2*c3)*c5)*c7)),
 -(((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*c6 - ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*s6)*(l_8x*(((((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*s6 + (s2*s3*c4 + s4*c2)*c6)*c7 - (-(-s2*s3*s4 + c2*c4)*s5 - s2*c3*c5)*s7)*c8 + (((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*c6 - (s2*s3*c4 + s4*c2)*s6)*s8) + l_8y*(-((((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*s6 + (s2*s3*c4 + s4*c2)*c6)*c7 - (-(-s2*s3*s4 + c2*c4)*s5 - s2*c3*c5)*s7)*s8 + (((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*c6 - (s2*s3*c4 + s4*c2)*s6)*c8) + l_8z*((((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*s6 + (s2*s3*c4 + s4*c2)*c6)*s7 + (-(-s2*s3*s4 + c2*c4)*s5 - s2*c3*c5)*c7)) - (((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*c6 - (s2*s3*c4 + s4*c2)*s6)*(-l_8x*(((((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*s6 + ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*c6)*c7 - (-(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*s5 + (-s1*s3 + c1*c2*c3)*c5)*s7)*c8 + (((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*c6 - ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*s6)*s8) - l_8y*(-((((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*s6 + ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*c6)*c7 - (-(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*s5 + (-s1*s3 + c1*c2*c3)*c5)*s7)*s8 + (((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*c6 - ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*s6)*c8) - l_8z*((((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*s6 + ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*c6)*s7 + (-(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*s5 + (-s1*s3 + c1*c2*c3)*c5)*c7)),
 -((((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*s6 + ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*c6)*s7 + (-(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*s5 + (-s1*s3 + c1*c2*c3)*c5)*c7)*(l_8x*(((((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*s6 + (s2*s3*c4 + s4*c2)*c6)*c7 - (-(-s2*s3*s4 + c2*c4)*s5 - s2*c3*c5)*s7)*c8 + (((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*c6 - (s2*s3*c4 + s4*c2)*s6)*s8) + l_8y*(-((((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*s6 + (s2*s3*c4 + s4*c2)*c6)*c7 - (-(-s2*s3*s4 + c2*c4)*s5 - s2*c3*c5)*s7)*s8 + (((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*c6 - (s2*s3*c4 + s4*c2)*s6)*c8) + l_8z*((((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*s6 + (s2*s3*c4 + s4*c2)*c6)*s7 + (-(-s2*s3*s4 + c2*c4)*s5 - s2*c3*c5)*c7)) - ((((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*s6 + (s2*s3*c4 + s4*c2)*c6)*s7 + (-(-s2*s3*s4 + c2*c4)*s5 - s2*c3*c5)*c7)*(-l_8x*(((((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*s6 + ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*c6)*c7 - (-(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*s5 + (-s1*s3 + c1*c2*c3)*c5)*s7)*c8 + (((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*c6 - ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*s6)*s8) - l_8y*(-((((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*s6 + ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*c6)*c7 - (-(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*s5 + (-s1*s3 + c1*c2*c3)*c5)*s7)*s8 + (((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*c6 - ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*s6)*c8) - l_8z*((((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*s6 + ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*c6)*s7 + (-(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*s5 + (-s1*s3 + c1*c2*c3)*c5)*c7)),

},

{0,
 -(l_8x*(((((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*s6 + ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*c6)*c7 - (-(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*s5 + (-s1*s3 + c1*c2*c3)*c5)*s7)*c8 + (((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*c6 - ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*s6)*s8) + l_8y*(-((((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*s6 + ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*c6)*c7 - (-(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*s5 + (-s1*s3 + c1*c2*c3)*c5)*s7)*s8 + (((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*c6 - ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*s6)*c8) + l_8z*((((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*s6 + ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*c6)*s7 + (-(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*s5 + (-s1*s3 + c1*c2*c3)*c5)*c7))*c1 + (-l_8x*(((((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*s6 + ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*c6)*c7 - (-(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*s5 + (s1*c2*c3 + s3*c1)*c5)*s7)*c8 + (((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*c6 - ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*s6)*s8) - l_8y*(-((((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*s6 + ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*c6)*c7 - (-(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*s5 + (s1*c2*c3 + s3*c1)*c5)*s7)*s8 + (((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*c6 - ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*s6)*c8) - l_8z*((((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*s6 + ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*c6)*s7 + (-(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*s5 + (s1*c2*c3 + s3*c1)*c5)*c7))*s1 - (-elbowOffsetX*((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5) + elbowOffsetX*(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4) + lowerArmLength*(-(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*s5 + (-s1*s3 + c1*c2*c3)*c5) - upperArmLength*(s1*s3 - c1*c2*c3))*c1 - (-elbowOffsetX*((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5) + elbowOffsetX*(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4) + lowerArmLength*(-(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*s5 + (s1*c2*c3 + s3*c1)*c5) - upperArmLength*(-s1*c2*c3 - s3*c1))*s1,
 -(l_8x*(((((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*s6 + ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*c6)*c7 - (-(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*s5 + (-s1*s3 + c1*c2*c3)*c5)*s7)*c8 + (((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*c6 - ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*s6)*s8) + l_8y*(-((((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*s6 + ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*c6)*c7 - (-(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*s5 + (-s1*s3 + c1*c2*c3)*c5)*s7)*s8 + (((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*c6 - ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*s6)*c8) + l_8z*((((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*s6 + ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*c6)*s7 + (-(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*s5 + (-s1*s3 + c1*c2*c3)*c5)*c7))*s1*s2 - (-l_8x*(((((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*s6 + ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*c6)*c7 - (-(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*s5 + (s1*c2*c3 + s3*c1)*c5)*s7)*c8 + (((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*c6 - ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*s6)*s8) - l_8y*(-((((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*s6 + ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*c6)*c7 - (-(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*s5 + (s1*c2*c3 + s3*c1)*c5)*s7)*s8 + (((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*c6 - ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*s6)*c8) - l_8z*((((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*s6 + ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*c6)*s7 + (-(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*s5 + (s1*c2*c3 + s3*c1)*c5)*c7))*s2*c1 - (-elbowOffsetX*((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5) + elbowOffsetX*(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4) + lowerArmLength*(-(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*s5 + (-s1*s3 + c1*c2*c3)*c5) - upperArmLength*(s1*s3 - c1*c2*c3))*s1*s2 + (-elbowOffsetX*((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5) + elbowOffsetX*(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4) + lowerArmLength*(-(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*s5 + (s1*c2*c3 + s3*c1)*c5) - upperArmLength*(-s1*c2*c3 - s3*c1))*s2*c1,
 (-s1*s3 + c1*c2*c3)*(-elbowOffsetX*((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5) + elbowOffsetX*(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4) + lowerArmLength*(-(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*s5 + (s1*c2*c3 + s3*c1)*c5)) - (-s1*s3 + c1*c2*c3)*(-l_8x*(((((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*s6 + ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*c6)*c7 - (-(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*s5 + (s1*c2*c3 + s3*c1)*c5)*s7)*c8 + (((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*c6 - ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*s6)*s8) - l_8y*(-((((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*s6 + ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*c6)*c7 - (-(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*s5 + (s1*c2*c3 + s3*c1)*c5)*s7)*s8 + (((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*c6 - ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*s6)*c8) - l_8z*((((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*s6 + ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*c6)*s7 + (-(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*s5 + (s1*c2*c3 + s3*c1)*c5)*c7)) - (s1*c2*c3 + s3*c1)*(-elbowOffsetX*((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5) + elbowOffsetX*(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4) + lowerArmLength*(-(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*s5 + (-s1*s3 + c1*c2*c3)*c5)) - (s1*c2*c3 + s3*c1)*(l_8x*(((((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*s6 + ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*c6)*c7 - (-(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*s5 + (-s1*s3 + c1*c2*c3)*c5)*s7)*c8 + (((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*c6 - ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*s6)*s8) + l_8y*(-((((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*s6 + ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*c6)*c7 - (-(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*s5 + (-s1*s3 + c1*c2*c3)*c5)*s7)*s8 + (((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*c6 - ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*s6)*c8) + l_8z*((((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*s6 + ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*c6)*s7 + (-(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*s5 + (-s1*s3 + c1*c2*c3)*c5)*c7)),
 -(-elbowOffsetX*((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5) + lowerArmLength*(-(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*s5 + (-s1*s3 + c1*c2*c3)*c5))*((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4) + (-elbowOffsetX*((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5) + lowerArmLength*(-(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*s5 + (s1*c2*c3 + s3*c1)*c5))*((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1) - ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*(-l_8x*(((((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*s6 + ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*c6)*c7 - (-(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*s5 + (s1*c2*c3 + s3*c1)*c5)*s7)*c8 + (((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*c6 - ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*s6)*s8) - l_8y*(-((((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*s6 + ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*c6)*c7 - (-(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*s5 + (s1*c2*c3 + s3*c1)*c5)*s7)*s8 + (((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*c6 - ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*s6)*c8) - l_8z*((((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*s6 + ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*c6)*s7 + (-(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*s5 + (s1*c2*c3 + s3*c1)*c5)*c7)) - ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*(l_8x*(((((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*s6 + ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*c6)*c7 - (-(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*s5 + (-s1*s3 + c1*c2*c3)*c5)*s7)*c8 + (((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*c6 - ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*s6)*s8) + l_8y*(-((((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*s6 + ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*c6)*c7 - (-(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*s5 + (-s1*s3 + c1*c2*c3)*c5)*s7)*s8 + (((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*c6 - ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*s6)*c8) + l_8z*((((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*s6 + ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*c6)*s7 + (-(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*s5 + (-s1*s3 + c1*c2*c3)*c5)*c7)),
 -(-(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*s5 + (-s1*s3 + c1*c2*c3)*c5)*(-l_8x*(((((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*s6 + ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*c6)*c7 - (-(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*s5 + (s1*c2*c3 + s3*c1)*c5)*s7)*c8 + (((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*c6 - ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*s6)*s8) - l_8y*(-((((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*s6 + ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*c6)*c7 - (-(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*s5 + (s1*c2*c3 + s3*c1)*c5)*s7)*s8 + (((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*c6 - ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*s6)*c8) - l_8z*((((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*s6 + ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*c6)*s7 + (-(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*s5 + (s1*c2*c3 + s3*c1)*c5)*c7)) - (-(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*s5 + (s1*c2*c3 + s3*c1)*c5)*(l_8x*(((((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*s6 + ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*c6)*c7 - (-(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*s5 + (-s1*s3 + c1*c2*c3)*c5)*s7)*c8 + (((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*c6 - ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*s6)*s8) + l_8y*(-((((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*s6 + ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*c6)*c7 - (-(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*s5 + (-s1*s3 + c1*c2*c3)*c5)*s7)*s8 + (((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*c6 - ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*s6)*c8) + l_8z*((((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*s6 + ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*c6)*s7 + (-(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*s5 + (-s1*s3 + c1*c2*c3)*c5)*c7)),
 -(((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*c6 - ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*s6)*(-l_8x*(((((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*s6 + ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*c6)*c7 - (-(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*s5 + (s1*c2*c3 + s3*c1)*c5)*s7)*c8 + (((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*c6 - ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*s6)*s8) - l_8y*(-((((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*s6 + ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*c6)*c7 - (-(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*s5 + (s1*c2*c3 + s3*c1)*c5)*s7)*s8 + (((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*c6 - ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*s6)*c8) - l_8z*((((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*s6 + ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*c6)*s7 + (-(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*s5 + (s1*c2*c3 + s3*c1)*c5)*c7)) - (((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*c6 - ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*s6)*(l_8x*(((((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*s6 + ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*c6)*c7 - (-(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*s5 + (-s1*s3 + c1*c2*c3)*c5)*s7)*c8 + (((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*c6 - ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*s6)*s8) + l_8y*(-((((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*s6 + ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*c6)*c7 - (-(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*s5 + (-s1*s3 + c1*c2*c3)*c5)*s7)*s8 + (((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*c6 - ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*s6)*c8) + l_8z*((((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*s6 + ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*c6)*s7 + (-(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*s5 + (-s1*s3 + c1*c2*c3)*c5)*c7)),
 -((((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*s6 + ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*c6)*s7 + (-(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*s5 + (-s1*s3 + c1*c2*c3)*c5)*c7)*(-l_8x*(((((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*s6 + ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*c6)*c7 - (-(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*s5 + (s1*c2*c3 + s3*c1)*c5)*s7)*c8 + (((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*c6 - ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*s6)*s8) - l_8y*(-((((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*s6 + ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*c6)*c7 - (-(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*s5 + (s1*c2*c3 + s3*c1)*c5)*s7)*s8 + (((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*c6 - ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*s6)*c8) - l_8z*((((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*s6 + ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*c6)*s7 + (-(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*s5 + (s1*c2*c3 + s3*c1)*c5)*c7)) - ((((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*s6 + ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*c6)*s7 + (-(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*s5 + (s1*c2*c3 + s3*c1)*c5)*c7)*(l_8x*(((((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*s6 + ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*c6)*c7 - (-(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*s5 + (-s1*s3 + c1*c2*c3)*c5)*s7)*c8 + (((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*c6 - ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*s6)*s8) + l_8y*(-((((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*s6 + ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*c6)*c7 - (-(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*s5 + (-s1*s3 + c1*c2*c3)*c5)*s7)*s8 + (((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*c6 - ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*s6)*c8) + l_8z*((((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*s6 + ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*c6)*s7 + (-(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*s5 + (-s1*s3 + c1*c2*c3)*c5)*c7)),

},

{0,
 -s1,
 s2*c1,
 -s1*s3 + c1*c2*c3,
 (-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1,
 -(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*s5 + (-s1*s3 + c1*c2*c3)*c5,
 ((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*c6 - ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*s6,
 (((-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*c5 + (-s1*s3 + c1*c2*c3)*s5)*s6 + ((-s1*c3 - s3*c1*c2)*c4 + s2*s4*c1)*c6)*s7 + (-(-(-s1*c3 - s3*c1*c2)*s4 + s2*c1*c4)*s5 + (-s1*s3 + c1*c2*c3)*c5)*c7,

},

{0,
 c1,
 s1*s2,
 s1*c2*c3 + s3*c1,
 (-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4,
 -(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*s5 + (s1*c2*c3 + s3*c1)*c5,
 ((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*c6 - ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*s6,
 (((-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*c5 + (s1*c2*c3 + s3*c1)*s5)*s6 + ((-s1*s3*c2 + c1*c3)*c4 + s1*s2*s4)*c6)*s7 + (-(-(-s1*s3*c2 + c1*c3)*s4 + s1*s2*c4)*s5 + (s1*c2*c3 + s3*c1)*c5)*c7,

},

{1,
 0,
 c2,
 -s2*c3,
 s2*s3*c4 + s4*c2,
 -(-s2*s3*s4 + c2*c4)*s5 - s2*c3*c5,
 ((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*c6 - (s2*s3*c4 + s4*c2)*s6,
 (((-s2*s3*s4 + c2*c4)*c5 - s2*s5*c3)*s6 + (s2*s3*c4 + s4*c2)*c6)*s7 + (-(-s2*s3*s4 + c2*c4)*s5 - s2*c3*c5)*c7,

}
}
end
cos, sin = math.cos, math.sin
upperArmLength, elbowOffsetX, lowerArmLength, shoulderOffsetY = 0.246,0.03,0.25, 0.234
l_8x, l_8y, l_8z = 0,0,0
local J = jac({0, 0,0,0, 0, 0,0,0})
print(#J)
for i, r in ipairs(J) do print(#r..":", unpack(r)) end