// Brian Khuu 2024 (All Rights Reserved)

clip_height = 30;
clip_width = 70;
clip_top_wall_thickness = 1;
clip_base_thickness = 2;

cardboard_thickness = 3;
cardboard_bottom_grip = 8;
clip_bottom_flap_thickness = 2;
cardboard_bottom_clip_opening = 3;

union()
{
    mirror([0,0,0])
        linear_extrude(height= clip_height, convexity= 4)
            import("clip.svg");
        
    mirror([0,1,0])
        linear_extrude(height= clip_height, convexity= 4)
            import("clip.svg");

    translate([clip_top_wall_thickness/2,0,clip_height/2])
        cube([clip_top_wall_thickness,clip_width,clip_height], center=true);

    difference()
    {
        union()
        {
            translate([-(cardboard_thickness+clip_bottom_flap_thickness)/2,0,clip_height/2])
                cube([cardboard_thickness+clip_bottom_flap_thickness,cardboard_bottom_grip,clip_height], center=true);
            hull()
            {
                translate([-(cardboard_thickness+clip_bottom_flap_thickness)/2,0,clip_height-clip_height/4])
                    cube([cardboard_thickness+clip_bottom_flap_thickness,cardboard_bottom_grip,clip_height/2], center=true);
                translate([-(cardboard_thickness+cardboard_bottom_clip_opening+clip_bottom_flap_thickness)/2,0,clip_height])
                    cube([cardboard_thickness+cardboard_bottom_clip_opening+clip_bottom_flap_thickness,cardboard_bottom_grip+1,0.1], center=true);
            }
        }
        union()
        {
            translate([-(cardboard_thickness)/2,0,clip_height/2+clip_base_thickness])
                cube([cardboard_thickness,cardboard_bottom_grip+1,clip_height], center=true);
            hull()
            {
                translate([-(cardboard_thickness)/2,0,clip_height-clip_height/4+clip_base_thickness])
                    cube([cardboard_thickness,cardboard_bottom_grip+1,clip_height/2], center=true);
                translate([-(cardboard_thickness+cardboard_bottom_clip_opening)/2,0,clip_height])
                    cube([cardboard_thickness+cardboard_bottom_clip_opening,cardboard_bottom_grip+1,0.1], center=true);
            }
        }
    }
}


if (0)
% translate([2,0,clip_height/2])
        cube([2,clip_width,clip_height], center=true);

if (0)
% translate([-2,0,clip_height/2])
        cube([2,clip_width,clip_height], center=true);