// Created in 2017 by Ryan A. Colyer (http://www.thingiverse.com/thing:2191927)
// Modified in 2024 by Brian K for cardboard use
// This work is released with CC0 into the public domain.
// https://creativecommons.org/publicdomain/zero/1.0/

// rounded screw point (safer for kids)
rounded_screw_point = true;

// Makedo Screws tends to be use for 10mm diameter holes 
thread_diam = 14;
roddiam = 5;
straightlen = 10.0;
angledlen = 6;
thread_pitch = 4;
cap_diam = 17;
screw_height = straightlen + angledlen;

// Phillips Screw Head
enable_phillips = true;
phillips_width = 7;
phillips_thick = 1.5;
phillips_straightdepth = 2.5;
slottedOnly = false;

// Most typical torx seems to be T20 https://www.electriciantalk.com/threads/most-common-torx-sizes.32688/
enable_torx = true;
torxTip = "T20";

quantity=1;

////// copied from threads.scad, http://www.thingiverse.com/thing:1686322 ////

screw_resolution = 0.2;  // in mm

// Provides standard metric thread pitches.
function ThreadPitch(diameter) =
  (diameter <= 64) ?
    lookup(diameter, [
      [2, 0.4],
      [2.5, 0.45],
      [3, 0.5],
      [4, 0.7],
      [5, 0.8],
      [6, 1.0],
      [7, 1.0],
      [8, 1.25],
      [10, 1.5],
      [12, 1.75],
      [14, 2.0],
      [16, 2.0],
      [18, 2.5],
      [20, 2.5],
      [22, 2.5],
      [24, 3.0],
      [27, 3.0],
      [30, 3.5],
      [33, 3.5],
      [36, 4.0],
      [39, 4.0],
      [42, 4.5],
      [48, 5.0],
      [52, 5.0],
      [56, 5.5],
      [60, 5.5],
      [64, 6.0]
    ]) :
    diameter * 6.0 / 64;

// This generates a closed polyhedron from an array of arrays of points,
// with each inner array tracing out one loop outlining the polyhedron.
// pointarrays should contain an array of N arrays each of size P outlining a
// closed manifold.  The points must obey the right-hand rule.  For example,
// looking down, the P points in the inner arrays are counter-clockwise in a
// loop, while the N point arrays increase in height.  Points in each inner
// array do not need to be equal height, but they usually should not meet or
// cross the line segments from the adjacent points in the other arrays.
// (N>=2, P>=3)
// Core triangles:
//   [j][i], [j+1][i], [j+1][(i+1)%P]
//   [j][i], [j+1][(i+1)%P], [j][(i+1)%P]
//   Then triangles are formed in a loop with the middle point of the first
//   and last array.
module ClosePoints(pointarrays) {
  function recurse_avg(arr, n=0, p=[0,0,0]) = (n>=len(arr)) ? p :
    recurse_avg(arr, n+1, p+(arr[n]-p)/(n+1));

  N = len(pointarrays);
  P = len(pointarrays[0]);
  NP = N*P;
  lastarr = pointarrays[N-1];
  midbot = recurse_avg(pointarrays[0]);
  midtop = recurse_avg(pointarrays[N-1]);

  faces_bot = [
    for (i=[0:P-1])
      [0,i+1,1+(i+1)%len(pointarrays[0])]
  ];

  loop_offset = 1;
  bot_len = loop_offset + P;

  faces_loop = [
    for (j=[0:N-2], i=[0:P-1], t=[0:1])
      [loop_offset, loop_offset, loop_offset] + (t==0 ?
      [j*P+i, (j+1)*P+i, (j+1)*P+(i+1)%P] :
      [j*P+i, (j+1)*P+(i+1)%P, j*P+(i+1)%P])
  ];

  top_offset = loop_offset + NP - P;
  midtop_offset = top_offset + P;

  faces_top = [
    for (i=[0:P-1])
      [midtop_offset,top_offset+(i+1)%P,top_offset+i]
  ];

  points = [
    for (i=[-1:NP])
      (i<0) ? midbot :
      ((i==NP) ? midtop :
      pointarrays[floor(i/P)][i%P])
  ];
  faces = concat(faces_bot, faces_loop, faces_top);

  polyhedron(points=points, faces=faces);
}

// This creates a vertical rod at the origin with external threads.  It uses
// metric standards by default.
module ScrewThread(outer_diam, height, pitch=0, tooth_angle=30, tolerance=0.4, tip_height=0, tooth_height=0, tip_min_fract=0) {

  pitch = (pitch==0) ? ThreadPitch(outer_diam) : pitch;
  tooth_height = (tooth_height==0) ? pitch : tooth_height;
  tip_min_fract = (tip_min_fract<0) ? 0 :
    ((tip_min_fract>0.9999) ? 0.9999 : tip_min_fract);

  outer_diam_cor = outer_diam + 0.25*tolerance; // Plastic shrinkage correction
  inner_diam = outer_diam - tooth_height/tan(tooth_angle);
  or = (outer_diam_cor < screw_resolution) ?
    screw_resolution/2 : outer_diam_cor / 2;
  ir = (inner_diam < screw_resolution) ? screw_resolution/2 : inner_diam / 2;
  height = (height < screw_resolution) ? screw_resolution : height;

  steps_per_loop_try = ceil(2*3.14159265359*or / screw_resolution);
  steps_per_loop = (steps_per_loop_try < 4) ? 4 : steps_per_loop_try;
  hs_ext = 3;
  hsteps = ceil(3 * height / pitch) + 2*hs_ext;

  extent = or - ir;

  tip_start = height-tip_height;
  tip_height_sc = tip_height / (1-tip_min_fract);

  tip_height_ir = (tip_height_sc > tooth_height/2) ?
    tip_height_sc - tooth_height/2 : tip_height_sc;

  tip_height_w = (tip_height_sc > tooth_height) ? tooth_height : tip_height_sc;
  tip_wstart = height + tip_height_sc - tip_height - tip_height_w;


  function tooth_width(a, h, pitch, tooth_height, extent) =
    let(
      ang_full = h*360.0/pitch-a,
      ang_pn = atan2(sin(ang_full), cos(ang_full)),
      ang = ang_pn < 0 ? ang_pn+360 : ang_pn,
      frac = ang/360,
      tfrac_half = tooth_height / (2*pitch),
      tfrac_cut = 2*tfrac_half
    )
    (frac > tfrac_cut) ? 0 : (
      (frac <= tfrac_half) ?
        ((frac / tfrac_half) * extent) :
        ((1 - (frac - tfrac_half)/tfrac_half) * extent)
    );


  pointarrays = [
    for (hs=[0:hsteps])
      [
        for (s=[0:steps_per_loop-1])
          let(
            ang_full = s*360.0/steps_per_loop,
            ang_pn = atan2(sin(ang_full), cos(ang_full)),
            ang = ang_pn < 0 ? ang_pn+360 : ang_pn,

            h_fudge = pitch*0.001,

            h_mod =
              (hs%3 == 2) ?
                ((s == steps_per_loop-1) ? tooth_height - h_fudge : (
                 (s == steps_per_loop-2) ? tooth_height/2 : 0)) : (
              (hs%3 == 0) ?
                ((s == steps_per_loop-1) ? pitch-tooth_height/2 : (
                 (s == steps_per_loop-2) ? pitch-tooth_height + h_fudge : 0)) :
                ((s == steps_per_loop-1) ? pitch-tooth_height/2 + h_fudge : (
                 (s == steps_per_loop-2) ? tooth_height/2 : 0))
              ),

            h_level =
              (hs%3 == 2) ? tooth_height - h_fudge : (
              (hs%3 == 0) ? 0 : tooth_height/2),

            h_ub = floor((hs-hs_ext)/3) * pitch
              + h_level + ang*pitch/360.0 - h_mod,
            h_max = height - (hsteps-hs) * h_fudge,
            h_min = hs * h_fudge,
            h = (h_ub < h_min) ? h_min : ((h_ub > h_max) ? h_max : h_ub),

            ht = h - tip_start,
            hf_ir = ht/tip_height_ir,
            ht_w = h - tip_wstart,
            hf_w_t = ht_w/tip_height_w,
            hf_w = (hf_w_t < 0) ? 0 : ((hf_w_t > 1) ? 1 : hf_w_t),

            ext_tip = (h <= tip_wstart) ? extent : (1-hf_w) * extent,
            wnormal = tooth_width(ang, h, pitch, tooth_height, ext_tip),
            w = (h <= tip_wstart) ? wnormal :
              (1-hf_w) * wnormal +
              hf_w * (0.1*screw_resolution + (wnormal * wnormal * wnormal /
                (ext_tip*ext_tip+0.1*screw_resolution))),
            r = (ht <= 0) ? ir + w :
              ( (ht < tip_height_ir ? ((2/(1+(hf_ir*hf_ir))-1) * ir) : 0) + w)
          )
          [r*cos(ang), r*sin(ang), h]
      ]
  ];

  ClosePoints(pointarrays);
}


// This creates a vertical rod at the origin with external auger-style
// threads.
module AugerThread(outer_diam, inner_diam, height, pitch, tooth_angle=30, tolerance=0.4, tip_height=0, tip_min_fract=0) {
  tooth_height = tan(tooth_angle)*(outer_diam-inner_diam);
  ScrewThread(outer_diam, height, pitch, tooth_angle, tolerance, tip_height, tooth_height, tip_min_fract);
}


// This inserts a Phillips tip shaped hole into its children.
// The rotation vector is applied first, then the position translation,
// starting from a position upward from the z-axis at z=0.
module PhillipsTip(width=7, thickness=0, straightdepth=0, position=[0,0,0], rotation=[0,0,0]) {
  thickness = (thickness <= 0) ? width*2.5/7 : thickness;
  straightdepth = (straightdepth <= 0) ? width*3.5/7 : straightdepth;
  angledepth = (width-thickness)/2;
  height = straightdepth + angledepth;
  extra_height = 0.001 * height;

  difference() {
    children();
    translate(position)
      rotate(rotation)
      union() {
        hull() {
          translate([-width/2, -thickness/2, -extra_height/2])
            cube([width, thickness, straightdepth+extra_height]);
          translate([-thickness/2, -thickness/2, height-extra_height])
            cube([thickness, thickness, extra_height]);
        }
        if (!slottedOnly)
        hull() {
          translate([-thickness/2, -width/2, -extra_height/2])
            cube([thickness, width, straightdepth+extra_height]);
          translate([-thickness/2, -thickness/2, height-extra_height])
            cube([thickness, thickness, extra_height]);
        }
      }
  }
}

////// end copied from threads.scad ////



////// start copied from KnurlSimplified.scad ////

module knurled_knob(h = 10,
                    d = 15,
                    knurling_step = 2.5,
                    knurling_depth = 1.5,
                    bevel_amount = 1.0) {
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

////// end copied from KnurlSimplified.scad ////

////// start copied from torx.scad ////
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

    if (bitsize_selector == "T20") {
        torx_profile(a=3.893, b=2.778, ri=0.871-0.015, re=0.307, hullD=2.4, h=4.07, h_override=h_override);
    } else if (bitsize_selector == "T30") {
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
////// end copied from torx.scad ////

module BareCardboardScrew(knob_height, rounded_screw_point) {
  translate([0,0,knob_height])
    AugerThread(thread_diam, roddiam, screw_height, thread_pitch, tooth_angle=15, tip_height=angledlen);
        knurled_knob(d=cap_diam, h=knob_height);

  if (rounded_screw_point)
  {      
      // Add rounded bit so it is safer for kids
      translate([0,0,knob_height])
        cylinder(h = straightlen+angledlen-1, r = roddiam/2, $fn=40);
      translate([0,0,knob_height+straightlen+angledlen-1])
        sphere(r = roddiam/2, $fn=40);
  }
  else
  {
      // Add poky bit so it can punch though without tools
      translate([0,0,knob_height])
        cylinder(h = straightlen+angledlen-1, r = roddiam/2, $fn=40);
      translate([0,0,knob_height+straightlen+angledlen-1])
        cylinder(h = 6, r1 = roddiam/2, r2 = 0, $fn=40);
  }
}



module CardboardScrew(knob_height, rounded_screw_point) {

    if (enable_phillips && enable_torx)
    {
      torxTip("T20",5.3) 
        PhillipsTip(phillips_width, phillips_thick, phillips_straightdepth)
          BareCardboardScrew(knob_height = knob_height, rounded_screw_point = rounded_screw_point);
    }
    else if (enable_phillips && enable_torx)
    {
      torxTip("T20",5.3) 
        PhillipsTip(phillips_width, phillips_thick, phillips_straightdepth)
          BareCardboardScrew(knob_height = knob_height, rounded_screw_point = rounded_screw_point);
    }
    else if (enable_phillips && enable_torx)
    {
      torxTip("T20",5.3) 
        PhillipsTip(phillips_width, phillips_thick, phillips_straightdepth)
          BareCardboardScrew(knob_height = knob_height, rounded_screw_point = rounded_screw_point);
    }
    else
    {
        BareCardboardScrew(knob_height = knob_height, rounded_screw_point = rounded_screw_point);
    }
}

// This creates an array of the specified number of its children, arranging
// them for the best chance of fitting on a typical build plate.
module MakeSet(quantity=1, x_len=30, y_len=30) {
  bed_yoverx = 1.35;
  x_space = ((x_len * 0.2) > 15) ? (x_len * 0.2) : 15;
  y_space = ((y_len * 0.2) > 15) ? (y_len * 0.2) : 15;
  function MaxVal(x, y) = (x > y) ? x : y;
  function MaxDist(x, y) = MaxVal((x_len*x + x_space*(x-1))*bed_yoverx,
    y_len*y + y_space*(y-1));
  function MinExtentX(x) = ((x >= quantity) ||
    (MaxDist(x+1, ceil(quantity/(x+1))) > MaxDist(x, ceil(quantity/x)))) ?
    x : MinExtentX(x+1);
  colmax = MinExtentX(1);

  for (i=[1:quantity]) {
    translate([(x_len + x_space)*((i-1)%colmax),
      (y_len + y_space)*floor((i-1)/colmax), 0])
      children();
  }
}

MakeSet(quantity, cap_diam, cap_diam)
  CardboardScrew(knob_height = 6, rounded_screw_point = rounded_screw_point);
