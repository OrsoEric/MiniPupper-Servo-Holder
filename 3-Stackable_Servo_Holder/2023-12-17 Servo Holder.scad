//Mangdang Servo Holder
// Version 1
//It's hard to support the clips
//	Version 2
//Make the clip a little easier
//Enlarge the servo clips so it can rest on the back
Dz=3;
Ty=1.5;
LGx=10;
Gy=1.0;
Dy=4;

//SCS0009 dimensions
//X axis
Lx_butt = (16.4+25.0);
Lx_flange_thickness = 1.5;
Lx_body_flange_gearbox = 23.0;
Lx_body_flange_gearbox_axel = 27.3;
//Y axis
Ly_butt = 23.2;
Ly_hole_interaxis = 27.0;
Ly_flange = 32.6;
//Z axis
Lz_depth = 12.5;

Lx_gearbox_thickness = Lx_body_flange_gearbox -Lx_flange_thickness -Lx_butt;

ly_flange_length = (Ly_flange-Ly_butt)/2;


///SCS0009 HOLDER
lx_base_thickness = 4;
ly_wall_thickness = 2;
lz_wall_thickness = 1;
l_margin = 0.5;

//Bax with the origin at the center of its base for easy stacking
module base_box( in_lx, in_ly, in_lz )
{
	translate([0, -in_ly/2, 0])
	{
        cube([in_lx, in_ly, in_lz], center=false);
    }
}

module cube_translate(size_vector, translate_vector)
{
    translate(translate_vector)
    cube(size_vector);
}

module hinge_triangle_up( Dz, Ty, LGx, Gx, Gy )
{
	//Gx hieght of the grip cannot exceed 2*Ty thickness
	//Dz = Z height of the hinge
	//Ty = Thickness of the hinge
	
	//HARDNESS OF THE HINGE
	//Hardness increases with the surface Dz*Ty
	//Hardness decreases with Length LGx
	linear_extrude(Dz)
	polygon
	(
		points=
		[
			//Bottom Left
			[0.0,0.0],
			//Thickenss of the hinge
			[0.0, Ty],
			//Start of the triangular bump
			[LGx -Gx, Ty],
			//Tip of the bump
			[LGx, Ty+Gy],
			//Tip of the hinge
			[LGx+1.5*Gx, Ty -0.5*Gy],
			//Tip base of the hinge
			[LGx+1.5*Gx, 0],
		],
		paths=
		[
			[0,1,2,3,4,5]
		],
		convexity=1
	);	
}

module hinge_triangle_down( Dz, Ty, LGx, Gx, Gy )
{
	//Flip and keep origin to the base of the long side
	translate([0,0,Dz])
	rotate([0,180,-180])
	hinge_triangle_up(Dz, Ty, LGx, Gx, Gy);
}

module hinge_male(Dz, Ty, LGx, Gy, Dy )
{
	//
	Gx = Dy/4;

	linear_extrude(Dz)
	polygon
	(
		points=
		[
			[0.0, -Dy/2],
			[0.0, Dy/2],
			[Dy, Dy/2],
			[Dy/4, 0],
			[Dy, -Dy/2],

		],
		paths=
		[
			[0,1,2,3,4]
		],
		convexity=1
	);	

	translate([0,Dy/2,0])
	hinge_triangle_up(Dz, Ty, LGx, Gx, Gy);

	translate([0,-Dy/2,0])
	hinge_triangle_down(Dz, Ty, LGx, Gx, Gy);
}

module hinge_female(Dz, Ty, LGx, Gy, Dy )
{
	//Male hinges with additional slack
	y_slack = 0.5;
	//
	Gx = Dy/4+y_slack/3;
	//Conserve the tips
	translate([0,Dy/2+y_slack/2,0])
	hinge_triangle_up(Dz, Ty, LGx, Gx, Gy);
	translate([0,-Dy/2-y_slack/2,0])
	hinge_triangle_down(Dz, Ty, LGx, Gx, Gy);
	//Add a box to cut out the space between hinges
	//translate([0,-Dy/2-y_slack/2,0])
	//cube([LGx+1.5*Gx,Dy+y_slack,Dz]);
	//Subtract a ribbon that leaves a triangle at the end
	linear_extrude(Dz)
	polygon
	(
		points=
		[
			[0.0, -Dy/2-y_slack/2],
			[0.0, Dy/2+y_slack/2],
			[LGx +1.5*Gx, Dy/2+y_slack/2],
			[LGx -1.0*Gx, 0.0],
			[LGx +1.5*Gx, -Dy/2-y_slack/2],
		],
		paths=
		[
			[0,1,2,3,4]
		],
		convexity=1
	);	
}

module servo()
{
	color("black")
	{
		base_box(Lx_butt, Ly_butt, Lz_depth);
		translate([Lx_butt,0,0])
			base_box(Lx_flange_thickness, Ly_flange, Lz_depth);
		translate([Lx_butt+Lx_flange_thickness,0,0])
			base_box(Lx_gearbox_thickness, Ly_butt, Lz_depth);
	}
}

//Attempt to draw the servo using polygon
//it's faster to stack four boxes
module servo_poly()
{
	polygon
	(
		points=
		[
			[0.0,Ly_butt/2],
			[100,0],
			[0,100],

		],
		paths=
		[
			[0,1,2],
			[]
		],
		convexity=100
	);		

}

module long_hinge(in_height, in_length, in_thickness, in_grip, in_reinforce )
{
	linear_extrude(in_height)
	polygon
	(
		points=
		[
			[0.0,0.0],
			[in_thickness,0],
			[in_thickness,in_length+in_grip+in_reinforce],
			[in_thickness/2,in_length+in_grip+in_reinforce],
			[-in_grip,in_length+in_reinforce],
			[-in_grip,in_length],
			[0,in_length],

		],
		paths=
		[
			[0,1,2,3,4,5,6]
		],
		convexity=1
	);	


}

module servo_holder()
{
	//Holes for the wires
	ly_wire = 9;
	lz_wire = 3;

	z_hinge_depth = 3;
	n_hinge_margin = 0.2;

	translate([0,0,0])
	difference()
	{
		union()
		{
			//Bottom Cover
			cube_translate
			(
				[
					lx_base_thickness+Lx_butt+0.5*l_margin,
					Ly_flange+1*l_margin,
					lz_wall_thickness
				],[
					0,
					-Ly_flange/2-l_margin/2,
					0
				]
			);

			//Base of the servo holder
			base_box(lx_base_thickness, Ly_flange+2*ly_wall_thickness+2*l_margin, lz_wall_thickness+Lz_depth+l_margin);

			//Walls
			//translate([lx_base_thickness,-Ly_flange/2-ly_wall_thickness,0])
				//base_box(Lx_body_flange_gearbox_axel-lx_base_thickness, ly_wall_thickness, Lz_depth);

			//Top Hinge
			//translate([lx_base_thickness,+Ly_flange/2+ly_wall_thickness,0])
				//base_box(Lx_body_flange_gearbox_axel-lx_base_thickness, ly_wall_thickness, Lz_depth);

			//Servo flange rest
			translate([lx_base_thickness,-Ly_flange/2-l_margin+ly_flange_length/2,lz_wall_thickness])
				base_box(Lx_butt+l_margin/2, ly_flange_length-l_margin, Lz_depth+l_margin);
			translate([lx_base_thickness,+Ly_flange/2+l_margin-ly_flange_length/2,lz_wall_thickness])
				base_box(Lx_butt+l_margin/2, ly_flange_length-l_margin, Lz_depth+l_margin);

			//Servo Hinge
			translate([lx_base_thickness,-Ly_flange/2-ly_wall_thickness/2+l_margin,0*lz_wall_thickness+0*l_margin/2])
			rotate([0,0,-90])
			long_hinge
			(
				Lz_depth+lz_wall_thickness,
				Lx_butt+Lx_flange_thickness+l_margin*1.0,
				ly_wall_thickness,
				2.5,
				1
			);

			//Servo Hinge
			translate([lx_base_thickness,+Ly_flange/2+ly_wall_thickness/2-l_margin,1*lz_wall_thickness+Lz_depth+0*l_margin/2])
			rotate([0,-180,-90])
			long_hinge
			(
				Lz_depth+lz_wall_thickness,
				Lx_butt+Lx_flange_thickness+l_margin*1.0,
				ly_wall_thickness,
				2.5,
				1
			);

			//Bottom Clip
			translate([1.0+n_hinge_margin,0,lz_wall_thickness+Lz_depth+l_margin])
			rotate([0,-90,180])
			hinge_male(Dz=Dz, Ty=Ty, LGx=LGx, Gy=Gy, Dy=Dy);
			
			//Minus Clip
			translate([lz_wall_thickness+Lx_butt/2+15,-Ly_flange/2+l_margin/2+ly_flange_length/2-z_hinge_depth/2-n_hinge_margin,lz_wall_thickness+Lz_depth+l_margin])
			rotate([90,-90,180])
			hinge_male(Dz=Dz, Ty=Ty, LGx=LGx, Gy=Gy, Dy=Dy);
			
			//Plus Clip
			translate([lz_wall_thickness+Lx_butt/2+15,Ly_flange/2-l_margin/2-ly_flange_length/2-z_hinge_depth/2+2*n_hinge_margin,lz_wall_thickness+Lz_depth+l_margin])
			rotate([90,-90,180])
			hinge_male(Dz=Dz, Ty=Ty, LGx=LGx, Gy=Gy, Dy=Dy);
		};	//End Union
		//Holes for servo wires
		//translate([0, Ly_butt/2-ly_wire/2+l_margin, Lz_depth/2-lz_wire/2])
			//base_box(lx_base_thickness,ly_wire,lz_wire);
		//translate([0, -Ly_butt/2+ly_wire/2-l_margin, Lz_depth/2-lz_wire/2])
			//base_box(lx_base_thickness,ly_wire,lz_wire);

		//Mating Bottom Clip
		translate([1,0,0])
		rotate([0,-90,180])
		hinge_female(Dz=Dz, Ty=Ty, LGx=LGx, Gy=Gy, Dy=Dy);

		//Mating Minus Clip
		translate([lz_wall_thickness+Lx_butt/2+15,-Ly_flange/2+l_margin/2+ly_flange_length/2-z_hinge_depth/2,0])
		rotate([90,-90,180])
		hinge_female(Dz=Dz, Ty=Ty, LGx=LGx, Gy=Gy, Dy=Dy);

		//Mating Plus Clip
		translate([lz_wall_thickness+Lx_butt/2+15,Ly_flange/2-l_margin/2-ly_flange_length/2-z_hinge_depth/2+n_hinge_margin,0])
		rotate([90,-90,180])
		hinge_female(Dz=Dz, Ty=Ty, LGx=LGx, Gy=Gy, Dy=Dy);

	}

	

}

servo_holder();

//translate([lx_base_thickness+l_margin,0,lz_wall_thickness+l_margin/2])
//servo();

//base_box(10, 20, 30);