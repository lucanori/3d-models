/* [Plate Dimensions] */
plate_width = 80; // [40:1:150]
plate_height = 200; // [80:1:300]
plate_thickness = 3; // [1:0.5:10]
corner_radius = 8; // [0:1:20]

/* [Handle Hole] */
hole_diameter = 50; // [20:1:80]
hole_distance_from_top = 40; // [20:1:100]
side_slot_height = 15; // [0:1:50]

/* [Text Area] */
font_size = 12; // [5:1:30]
text_relief_height = 1; // [0.5:0.1:3]
line_spacing_multiplier = 1.3; // [1.0:0.1:2.0]
side_margin = 10; // [5:1:30]
bottom_margin = 10; // [5:1:30]

/* [Text Lines - Auto-calculated max lines based on available height] */
text_lines = [
    "DO NOT",
    "DISTURB",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    ""
];

/* [Hidden] */
area_below_hole_height = plate_height - hole_distance_from_top - hole_diameter/2;
text_area_width = plate_width - 2 * side_margin;
text_area_height = area_below_hole_height - bottom_margin - 10;
single_line_height = font_size * line_spacing_multiplier;
max_lines_that_fit = floor(text_area_height / single_line_height);

module rounded_rectangle(width, height, thickness, radius) {
    if (radius > 0) {
        hull() {
            translate([radius, radius, 0])
                cylinder(h=thickness, r=radius, $fn=30);
            translate([width-radius, radius, 0])
                cylinder(h=thickness, r=radius, $fn=30);
            translate([radius, height-radius, 0])
                cylinder(h=thickness, r=radius, $fn=30);
            translate([width-radius, height-radius, 0])
                cylinder(h=thickness, r=radius, $fn=30);
        }
    } else {
        cube([width, height, thickness]);
    }
}

function count_non_empty_lines(lines, index=0, count=0) =
    index >= len(lines) ? count :
    lines[index] != "" ? count_non_empty_lines(lines, index+1, count+1) :
    count_non_empty_lines(lines, index+1, count);

module multiline_centered_text() {
    actual_line_count = count_non_empty_lines(text_lines);
    lines_to_render = min(actual_line_count, max_lines_that_fit);
    
    vertical_center_y = bottom_margin + text_area_height/2;
    
    translate([plate_width/2, vertical_center_y, plate_thickness]) {
        linear_extrude(height=text_relief_height) {
            for (i = [0 : min(len(text_lines), max_lines_that_fit) - 1]) {
                if (text_lines[i] != "") {
                    vertical_offset = single_line_height * ((lines_to_render - 1) / 2 - i);
                    translate([0, vertical_offset, 0])
                        text(text_lines[i], 
                             size=font_size, 
                             font="Liberation Sans:style=Bold", 
                             halign="center", 
                             valign="center",
                             $fn=30);
                }
            }
        }
    }
}

echo(str("Available height for text: ", text_area_height, "mm"));
echo(str("Height per line: ", single_line_height, "mm"));
echo(str("Maximum lines that fit: ", max_lines_that_fit));
echo(str("Non-empty lines provided: ", count_non_empty_lines(text_lines)));

union() {
    difference() {
        rounded_rectangle(plate_width, plate_height, plate_thickness, corner_radius);
        
        translate([plate_width/2, plate_height - hole_distance_from_top, -1])
            cylinder(h=plate_thickness + 2, d=hole_diameter, $fn=60);
        
        if (side_slot_height > 0) {
            translate([plate_width/2, 
                       plate_height - hole_distance_from_top - side_slot_height/2, 
                       -1])
                cube([plate_width, side_slot_height, plate_thickness + 2]);
        }
    }
    
    multiline_centered_text();
}

% translate([side_margin, bottom_margin, plate_thickness])
    cube([text_area_width, text_area_height, 0.1]);