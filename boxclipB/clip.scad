// Brian Khuu 2024 (All Rights Reserved)

clip_height = 20;
clip_width = 70/2;
clip_base_thickness = 1;

flap_blocker_height = 40;

cardboard_thickness = 2.5;
cardboard_bottom_grip = 30;

union()
{
    mirror([0,0,0])
        linear_extrude(height= clip_height, convexity= 4)
            import("clip.svg");
        
    translate([clip_base_thickness/2,clip_width/2,clip_height/2])
        cube([clip_base_thickness,clip_width,clip_height], center=true);

    translate([-cardboard_thickness/2,clip_width/2,-clip_base_thickness/2+flap_blocker_height/2])
        cube([cardboard_thickness,clip_width,clip_base_thickness], center=true);
        
    translate([-clip_base_thickness/2-cardboard_thickness,clip_width/2,flap_blocker_height/2])
        cube([clip_base_thickness,clip_width,flap_blocker_height], center=true);
}


if (0)
% translate([2,0,clip_height/2])
        cube([2,clip_width,clip_height], center=true);

if (0)
% translate([-2,0,clip_height/2])
        cube([2,clip_width,clip_height], center=true);