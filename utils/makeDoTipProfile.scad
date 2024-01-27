// Makedo Style Hex Head
// By Brian Khuu 2024
// Licence: GNU v3 or higher
module makedoStyleScrewHeadModel(h, tol = 0)
{
    difference()
    {
        cylinder(r1=13/2+tol, r2=13/2-tol, h = h, $fn=60);
        translate([0,0,-0.01])
            cylinder(r1=5-tol, r2=5+tol, h = h+0.02, $fn=6);
    }
}

module makedoStyleScrewHead(h, tol=0)
{
    difference()
    {
        children();
        translate([0,0,-0.01])
            makedoStyleScrewHeadModel(h=h, tol=tol);
    }
}

translate([0,0,0])
    makedoStyleScrewHeadModel(h=2);
    
translate([20,0,0])
    makedoStyleScrewHead(h=4, tol = 0.2)
        cylinder(d=20, h = 10, $fn=128);
        

%cube([5,8,10], center=true);