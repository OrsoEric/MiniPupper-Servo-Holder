//Test Clip Hinges that can be 3D printed

//Strength
//Too much and it breaks
//Too little and it doesn't clip
//Strength increases with cross section of the beam
//	Dz *Ty
//Strength decreases with length of the beam
//	LGx
//Strength increases with size of the grip
//	Gy


//Test 1
//Dz=5, Ty=2, LGx=50, Gy=2, Dy=6
//Fitting is good, it could be a little tighter on the head
//The ratio Gy/Gx grip needs to be steeper to make good contact
//It's very weak
//Strenght = Dz*Ty/LGx = 0.2mm
//Gy=2mm Strength = 0.4 mm2

//Test 2
//Increase Strength
//Steeper grip
//Dz=5, Ty=2, LGx=20, Gy=1, Dy=6
//Strength = Gy *Dz*Ty/LGx = 1 *5*2 /20 = 0.5 mm2
//Feedback
//still too weak, the grip is too little, gap is too wide

//Test 3
//Increase strength, increase grip, reduce gap, make full sleeve
//Dz=5, Ty=2, LGx=15, Gy=1.5, Dy=4
//Strength = Gy *Dz*Ty/LGx = 1.5 *5*2 /15 = 1.0 mm2

//TEST4
//Double sided 

Dz=3;
Ty=1.5;
LGx=10;
Gy=1.0;
Dy=3;


module cube_translate(size_vector, translate_vector)
{
    translate(translate_vector)
    cube(size_vector);
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
			[LGx -1.5*Gx, 0.0],
			[LGx +1.5*Gx, -Dy/2-y_slack/2],
		],
		paths=
		[
			[0,1,2,3,4]
		],
		convexity=1
	);	
}

//cube_translate([1, 2, 3], [4, 5, 6]);

//long_hinge(10, 100, 5, 3, 1 );

//hinge_triangle_up( 10, 3, 50, 2, 6 );
//hinge_triangle_down( 10, 3, 50, 2, 6 );

module test_hinge_male()
{
	cube_translate([5,20,5],[-5,-10,0]);
	hinge_male( Dz=5, Ty=2, LGx=15, Gy=1.5, Dy=4 );
}

module test_hinge_female()
{
	LGx = 15;
	cube_translate([5,20,5],[0,-10,5]);

	difference()
	{
		cube_translate([LGx*1.2, 20, 5],[0, -10, 0]);
		hinge_female( Dz=5, Ty=2, LGx=15, Gy=1.5, Dy=4 );
	}
}

test_hinge_male();
test_hinge_female();