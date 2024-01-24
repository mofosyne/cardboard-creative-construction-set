// Customizable torx shape
// by espr14 is licensed under the Creative Commons - Attribution license.
// https://www.thingiverse.com/thing:3600358
// Description
// It's just a torx shape so you have to set all the variables to get standardized torx bolt head or screwdriver head. Table is copied from the ISO norm.
// https://www.sis.se/api/document/preview/615502/

$fn=128;

tx=[5.557,3.972,1.206-0.015,0.454,4.95,2.4]; ///T30
//tx=[22.245,15.834,4.913,1.724,11.35,9.5]; ///T100


a=tx[0];
b=tx[1];
ri=tx[2];
re=tx[3];
hullD=tx[5];

h=tx[4];

////////////////////////////////

linear_extrude(h) difference(){
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

////////////////////////////////

module t(v=[0,0,0]){translate(v) children();}
module r(a=[0,0,0]){rotate(a) children();}
module tr(v=[0,0,0],a=[0,0,0]){t(v) r(a) children();}
module rt(a=[0,0,0],v=[0,0,0]){r(a) t(v) children();}
module u(){union() children();}