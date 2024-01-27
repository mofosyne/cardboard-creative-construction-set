/*
MODULE: Knurl Simplified (Remixed from a design by franpoli by mofosyne)

Modified knurled_button.scad from https://github.com/franpoli/OpenSCADutil/blob/master/knurled_knob/knurled_knob.scad by franpoli
to just get the Knurl shape, so it can be reused in other context like a Knurl screw for cardboard.

This Module licence is:
 GNU General Public License v3.0
 Permissions of this strong copyleft license are conditioned on making available complete source
 code of licensed works and modifications, which include larger works using a licensed work, under
 the same license. Copyright and license notices must be preserved. Contributors provide an express
 grant of patent rights.
*/
  
module knurled_knob(h = 10,
                    d = 15,
                    knurling_step = 2.5,
                    knurling_depth = 1.5,
                    bevel_amount = 1.5) {
  /*
  MODULE: Knurl Simplified (Remixed from a design by franpoli by mofosyne)

  Modified knurled_button.scad from https://github.com/franpoli/OpenSCADutil/blob/master/knurled_knob/knurled_knob.scad by franpoli
    to just get the Knurl shape, so it can be reused in other context like a Knurl screw for cardboard.

  This Module licence is:
     GNU General Public License v3.0
     Permissions of this strong copyleft license are conditioned on making available complete source
     code of licensed works and modifications, which include larger works using a licensed work, under
     the same license. Copyright and license notices must be preserved. Contributors provide an express
     grant of patent rights.
  */

  knob_height = h;
  knob_diameter = d;

  // Resolution
  $fa=2; // default minimum facet angle
  $fs=0.2; // default minimum facet size

  // Nth turn of a cylinder of the same height as its diameter
  function twist_amount(n) = 360/n*knob_height/knob_diameter;

  // Browse the paired list and retains the length values,
  // find the closest length to the preffered value
  // output the corresponding step value
  function get_ideal_step(paired_list, desired_length)
    = max([ for (i = [0 : len(paired_list)-1 ],j = [0 : 1])
        if (j % 2 != 0)
          if (abs(paired_list[i][j]-desired_length)
              == min( [for (i = [0 : len(paired_list)-1 ], j = [1 : 2 : 1])
                    abs(paired_list[i][j]-desired_length)]))
             paired_list[i][j-1]]);

  // Generates a paired list of step values and circle arc lengths
  pair_steps_and_lengths = [ for (i = [1 : 360]) if (90 % i == 0) [90/i, knob_diameter*3.14/i/4] ];

  module chamfer(chamfer_size, chamfer_z_position)
  {
    translate([0, 0, chamfer_z_position])
      rotate_extrude(angle = 360, convexity = 2)
      translate([knob_diameter/2, 0, 0]) rotate([0, 0, 45])
      square(size = chamfer_size, center = true);
  }

  module knurl_pattern() {
    for (j = [-1 : 2 : 1]) translate([0, 0, knob_height/2]) {
      linear_extrude(height = knob_height, center = true, convexity = 10, twist = j*twist_amount(4)) {
        for (i = [0 : get_ideal_step(pair_steps_and_lengths, knurling_step) : 360])
          rotate([0, 0, i]) translate([-knob_diameter/2, 0, 0]) circle(d=knurling_depth, $fn=3);
      }
    }
  }

  // Main
  difference()
  {
    cylinder(h=knob_height, d=knob_diameter);

    // Bevel
    chamfer(bevel_amount, knob_height);
    chamfer(bevel_amount, 0);

    // Knurl
    knurl_pattern();
  }
}

// Customizer
knurled_knob();
