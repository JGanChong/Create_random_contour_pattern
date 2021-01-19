/*  Creates randomly generated contour maps with user settings
 *  
 *  
 * Macro tested with ImageJ 1.53g, Java 1.8.0_172 (64bit) Windows 10
 * Macro by Johnny Gan Chong email:behappyftw@g.ucla.edu 
 * January 2021
 */


setOption("ExpandableArrays", true);
 
//User Variables:
image_width = 5000; //image width
image_height = 3000; //image height
ROI_height = 100; //max height of circles
ROI_width = 100; //max width of circles
minheight = 50; //Minimum circle height (good to avoid flat ovals)
minwidth = 50; //Minimum circle width (good to avoid flat ovals)

min_distance = 100; //Minimum distance between circles. If the distance is tsoo big, circles wont be able to fit and it will give an error. 
number_of_ROI = 700; //Number of circles. If too many circles are set here that can not fit the image it will give an error. 

interval = 5; //interval between black and white. Increase interval to increase distance between black and white lines
blackratio = 2; //change value to create double lines

Use_BorderToBorder = false; //Measure from center of circles or border (set true if you want 0 circle overlaps)
max_try = 500; //How many iterations to go over before deciding its too much



//chanage calculation if border to border is true
if (Use_BorderToBorder == true) {
	min_distance = min_distance + ((sqrt(pow(ROI_height,2)+pow(ROI_width,2)))/2);
}

newImage("Untitled", "8-bit black", image_width, image_height, 1);
//get image dimensions
getDimensions(width, height, channels, slices, frames);


//Create Array to store good ROI centers
goodx = newArray;
goody = newArray;

//create first point
randx = (random*width);
randy = (random*height);
randx = round(randx);
randy = round(randy);
goodx[0] = randx;
goody[0] = randy;


//Iterate to find other points that match user settings
for (i = 1; i < number_of_ROI; i++) {
	pass = 0;
	count = 0;
	try = 0;

	//Loop over randomly generated X and Y
	while (pass == 0) {
		try++;
		randx = (random*width);
		randy = (random*height);
		

		//Check that randomly generated (x,y) satisfy distance
		for (x = 0; x < goodx.length; x++) {
			
			distance = sqrt( pow(randx-goodx[x],2) + pow(randy-goody[x],2) );


			if (distance > min_distance) {
				count++;				
			}
			
			
		}
		
		if (count == goodx.length) {
			goodx[i] = randx;
			goody[i] = randy;
			
			pass = 1;
		}
		else {
			count = 0;
		}

		//exit if iterations exceed user set value
		if (try == max_try) {
			exit("No arrangement found to accomodate user settings after "+try+" trials. Please retry or change settings" );	
		}
	}
		
}

nHeight = ROI_height-minheight;
nWidth = ROI_width-minwidth;
for (i = 0; i < goodx.length; i++) {
	makeOval(goodx[i], goody[i], (random*nWidth)+minwidth, (random*nHeight)+minheight);
	run("Fill", "slice");
	run("Select None");
}

mean = ((ROI_height+ ROI_width)/2)/2;
run("Gaussian Blur...", "sigma="+mean);
check=1;
for (i = 0; i < (round(250/interval)); i++) {
	if (check != blackratio) {
		changeValues(interval*i, interval*(i+1), 0);
		check ++;
	
	}
	else {
		if(check == blackratio) {
		changeValues(interval*i, interval*(i+1), 255);
		check = 1;
		
		}	
	}
}
run("Find Edges");
