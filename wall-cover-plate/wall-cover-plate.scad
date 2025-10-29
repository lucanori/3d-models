plate_width = 120; // [80:1:200]
plate_height = 70; // [50:1:150]
plate_thickness = 3; // [1:0.1:10]
corner_radius = 5; // [0:0.1:20]
screw_hole_offset_x = 45; // [20:1:90]
screw_hole_offset_y = 25; // [10:1:60]
screw_hole_diameter = 4; // [2:0.1:8]
add_countersink = false; // [true:false]
countersink_diameter = 8; // [4:0.1:12]
countersink_depth = 2; // [0.5:0.1:5]


module plate_profile() {
    effective_radius = min(corner_radius, plate_width/2, plate_height/2);
    offset(r = -effective_radius)
        offset(r = effective_radius)
            square([plate_width, plate_height], center = true);
}

module screw_hole() {
    translate([0, 0, -0.1])
        cylinder(h = plate_thickness + 0.2, d = screw_hole_diameter, center = false);
    if (add_countersink) {
        effective_countersink_depth = min(countersink_depth, plate_thickness);
        translate([0, 0, plate_thickness - effective_countersink_depth])
            cylinder(h = effective_countersink_depth + 0.1, d1 = screw_hole_diameter, d2 = countersink_diameter, center = false);
    }
}

module wall_cover_plate() {
    difference() {
        linear_extrude(height = plate_thickness)
            plate_profile();
        for (x = [-screw_hole_offset_x, screw_hole_offset_x])
            for (y = [-screw_hole_offset_y, screw_hole_offset_y])
                translate([x, y, 0])
                    screw_hole();

    }
}

wall_cover_plate();