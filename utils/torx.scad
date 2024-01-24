// Customizable torx shape
// by espr14 is licensed under the Creative Commons - Attribution license.
// modified by mofosyne to be easier to use as a lib
// https://www.thingiverse.com/thing:3600358
// Description
// It's just a torx shape so you have to set all the variables to get standardized torx bolt head or screwdriver head. Table is copied from the ISO norm.
// https://www.sis.se/api/document/preview/615502/ Table 3

// Pull requests to improve this script is welcomed

module torxModel(bitsize_selector, h_override = 0)
{
    // Torx Profile Smoothing
    $fn=128;
 
    module t(v=[0,0,0]){translate(v) children();}
    module r(a=[0,0,0]){rotate(a) children();}
    module tr(v=[0,0,0],a=[0,0,0]){t(v) r(a) children();}
    module rt(a=[0,0,0],v=[0,0,0]){r(a) t(v) children();}
    module u(){union() children();}
    
    module torx_profile(a, b, ri, re, hullD, h, h_override) {
        linear_extrude(h_override?h_override:h) 
            difference(){
            u(){
                circle(d=(a+b)/2);
                for(i=[0:360/6:360]) hull(){
                    rt(i,[a/2-re,0]) circle(r=re);
                    circle(d=hullD);
                }
            }
            for(i=[-30:360/6:360]) hull(){
                rt(i,[b/2+ri,0]) circle(r=ri);
            }
        }
    }

    if (bitsize_selector == "T30") {
        torx_profile(a=5.557, b=3.972, ri=1.206-0.015, re=0.454, hullD=2.4, h=4.95, h_override=h_override);
    } else if (bitsize_selector == "T100") {
        torx_profile(a=22.245, b=15.834, ri=4.913, re=1.724, hullD=9.5, h=11.35, h_override=h_override);
    }
}

module torxTip(bitsize_selector, h = 0)
{
    difference()
    {
        children();
        translate([0,0,-0.01])
            torxModel(bitsize_selector=bitsize_selector, h_override=h);
    }
}

translate([0,0,0])
    torxModel("T100");
    
translate([20,0,0])
    torxTip("T30", h=6)
        cylinder(d=8, h = 5, $fn=128);