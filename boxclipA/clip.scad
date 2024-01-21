
// https://www.thingiverse.com/thing:39983/files Flexible Belt Clip By Austin January 02, 2013

clip_height = 30;
clip_width = 70;
clip_base_thickness = 1.5;

cardboard_thickness = 2.5;
cardboard_bottom_grip = 30;

union()
{
    mirror([0,0,0])
        linear_extrude(height= clip_height, convexity= 4)
            import("clip.svg");
        
    mirror([0,1,0])
        linear_extrude(height= clip_height, convexity= 4)
            import("clip.svg");

    translate([clip_base_thickness/2,0,clip_height/2])
        cube([clip_base_thickness,clip_width,clip_height], center=true);

    translate([-cardboard_thickness/2,0,clip_base_thickness/2])
        cube([cardboard_thickness,cardboard_bottom_grip,clip_base_thickness], center=true);
        
    translate([-clip_base_thickness/2-cardboard_thickness,0,clip_height/2])
        cube([clip_base_thickness,cardboard_bottom_grip,clip_height], center=true);
}


if (0)
% translate([2,0,clip_height/2])
        cube([2,clip_width,clip_height], center=true);

if (0)
% translate([-2,0,clip_height/2])
        cube([2,clip_width,clip_height], center=true);