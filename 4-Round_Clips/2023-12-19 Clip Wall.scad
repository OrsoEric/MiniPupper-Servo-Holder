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
//Much better! Now I can print the tiny clips at maximum strenght and precision
//They are super fast to print
Dz=3;
Ty=1.5;
LGx=10;
Gy=1.0;
Dy=3;

//TEST5 ROUND CLIPS with doub
//iH=2, iT=2, iL=15, iG=1, iA=2
//Much better!
//I can remove the aperture as parameter and leave it 2*Gap
//Side slack is much looser than vertical slack
//v_slack = 0.4 h_slack = 0.1
//Make three tests
//iH=2, iT=2, iL=15, iG=1 excellent tollerance, easy to remove
//iH=2, iT=2, iL=12, iG=1 excellent tollerance, hard to remove, aperture should be a tiny bit larger
//iH=2, iT=2, iL=12, iG=1.2 very hard to enter, impossible to remove. more aperture.

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

//Make a wall with embedded clips
module wall_double_clips( iDz, iTy, iLGx, iGy, iDy, ia_wall, in_female_clips )
{
	cube_translate( ia_wall,[0,0,0]);

}


//test_hinge_male();
//test_hinge_female();

module double_male_hinge( iDz, iTy, iLGx, iGy, iDy )
{
	hinge_male( Dz=iDz, Ty=iTy, LGx=iLGx, Gy=iGy, Dy=iDy );
	rotate([-180,-180,0])
	hinge_male( Dz=iDz, Ty=iTy, LGx=iLGx, Gy=iGy, Dy=iDy );
}

//translate([0,-30,0])
//double_male_hinge( iDz=2.5, iTy=2, iLGx=12, iGy=1, iDy=3 );

//Draw a pie
//iZ			depth of the pie
//iD			Diameter of the pie
//i_angle_start	
//i_angle_end
//	start angle and end angle decide the orientation and size of the slice
module pie( iZ, iD, i_angle_start, i_angle_end )
{
	angle_total = abs(i_angle_end -i_angle_start);


	translate([0,0,iZ/2])
	rotate([0,0,-180-i_angle_start])
	rotate_extrude( angle=angle_total, $fn=100)
	translate([iD/4,0,0])
	square([iD/2,iZ], center=true);


}

//Clip with round profile and compliant fork
//iH	Depth of the clip on the Z axis. Increases strength
//iT	Thickness of the clip arms on the Y axis. Increases strength
//iL	Total length of the clip on X axis. Decreases strength
//iG	Grip, how far the round element protrudes outward on Y axis
//		Forces the clips inward during insertion
//		Retain clips once inserted
//		Cannot exceed Pitch or the clips will interfere and the clip won't enter
//iA	Aperture, gap between the two clips. Need to accomodate flexing and gap when inserting
module clip_round( iH, iT, iL, iG )
{
	//Aperture is twice the gap
	A = 2*iG;
	//Pitch between arms
	P = A+iT;
	//Bottom Arm of the clip
	cube_translate([iL-iG-iT, iT, iH],[0, -iT/2-P/2, 0]);
	//Top Arm of the clip
	cube_translate([iL-iG-iT, iT, iH],[0, -iT/2+P/2, 0]);
	//Bottom Round Clip
	translate([iL-iG-iT,+iT/2-P/2,0])
	pie(iH, (iT+iG)*2, 0, 180);
	//Top Round Clip
	translate([iL-iG-iT,-iT/2+P/2,0])
	pie(iH, (iT+iG)*2, 180, 360);
}

//Base clips, with an element joining the two clips
module clip_round_male( iH, iT, iL, iG, iA )
{
	difference()
	{
		union()
		{
			clip_round(iH, iT, iL, iG);
			//Join the two arms
			cube_translate([iT+2*iG/2,2*iG, iH],[0, -2*iG/2, 0]);
		}
		//Extrude from the joinage to make it smooth		
		translate([iT+2*iG/2,0,0])
		pie(iH, 2*iG, 90, 270);
	}
}

//Create an element with male round clip on both sides
module double_clip_round_male( iH, iT, iL, iG, iA )
{

	clip_round_male( iH, iT, iL, iG, iA );
	rotate([-180,-180,0])
	clip_round_male( iH, iT, iL, iG, iA );
}

//Meant to be extruded from a volume
//Added tollerances to make sure male and female of same parameters mate
//base clip with added tollerances
//Add an element to aid with clip retention
module clip_round_female( iH, iT, iL, iG )
{
	
	v_slack = 0.4;
	h_slack = 0.1;
	Hslack = iH+v_slack;
	Lslack = iL+h_slack;
	Tslack = iT+h_slack;
	translate([0,0,-v_slack/2])
	union()
	{
		//Base clips
		clip_round(Hslack, Tslack, Lslack, iG);
		
		difference()
		{
			//Subtract space between arms
			cube_translate([Lslack, 2*iG, Hslack],[0, -2*iG/2, 0]);
			//Leve wedge to help with retention
			translate([Lslack,0,0])
			pie(Hslack, 2*iG, 90, 270);
		}
	}
}




//Make a volume with a female clip slot inside
module test_clip_round_female(iH, iT, iL, iG)
{
	//Depth of the walls below and above the slot
	Zwall = 1;
	//Cube size to enclose the female slot
	Lcube = iL*1.2;
	Wcube = (2*iT+2*iG+2*iG)*1.5;
	Hcube = iH +2*Zwall;
	
	difference()
	{
		cube_translate([Lcube, Wcube, Hcube],[0, -Wcube/2, -Zwall]);
		clip_round_female( iH=iH, iT=iT, iL=iL, iG=iG);
	}
}

H=2;
T=2;
L=12;
G=1.2;

//Test clip inside the female clip
//clip_round_male( iH=2, iT=2, iL=15, iG=1, iA=2);
//Test double clip inside the female clip
//double_clip_round_male( iH=H, iT=T, iL=L, iG=G );
//Test block with a female clip
test_clip_round_female( iH=H, iT=T, iL=L, iG=G );
//Double clip for printing
translate([6,-12,-1])
double_clip_round_male( iH=H, iT=T, iL=L, iG=G );

