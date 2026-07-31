// import everything necessary to make sound.
import ddf.minim.*;
import ddf.minim.ugens.*;
import processing.serial.*;

JSONObject json, json3, json2, json4;
JSONArray points, points2, points3, points4;

float zoomVal = 1;
float chartOffset = 0;
float scaleIntensity = 1;
PShape samosa;
// CHANGED: Instantiated both lists to hold screen coordinates for matching
ArrayList<Float> xCoords = new ArrayList<>();
ArrayList<Float> yCoords = new ArrayList<>();
float playHeadX = 50;

Line ampLine;
// create all of the variables that will need to be accessed in
// more than one methods (), draw(), stop()).
Minim minim;
AudioOutput out;
Summer mix;
Driver d1, d2, d3, d4;
Serial myPort;

void setup() {
  size(2000, 1000);
  //samosa = loadShape("Samosa.obj");
  //ortho();

  printArray(Serial.list());

  // Open the port you are using at the rate you want:
  myPort = new Serial(this, Serial.list()[5], 115200);

  // Send a capital "A" out the serial port
  json = loadJSONObject("dump_1782907724291_1782821998.json");
  points = json.getJSONArray("sensorData");
  json2 = loadJSONObject("dump_1782993630435_1782909643.json");
  points2 = json2.getJSONArray("sensorData");
  json3 = loadJSONObject("dump_1782821138749_1782734742.json");
  points3 = json3.getJSONArray("sensorData");
  json4 = loadJSONObject("dump_1783168087121_data.json");
  points4 = json4.getJSONArray("sensorData");

  rectMode(CENTER);
  minim = new Minim( this );
  out = minim.getLineOut( Minim.MONO, 2048 );
  mix = new Summer();
  //  wave = new Oscil(440.0f, 0.0f, Waves.SINE);
  // wave.patch(out);
  color c = color(0, 204, 0);  // Define color 'c'
  d1 = new Driver(points, c, 440.0f, samosa, new PVector(width*1/5, height/5), false);
  d2 = new Driver(points2, 698.46f, samosa, new PVector(width*2/5, height/5), false);
  d3 = new Driver(points3, 523.25, samosa, new PVector(width*3/5, height/5), true);
  d4 = new Driver(points4, 880.0f, samosa, new PVector(width*4/5, height/5), false);

  mix.patch(out);
  hint(DISABLE_STROKE_PERSPECTIVE);
  hint(DISABLE_DEPTH_TEST);
}

void draw() {
  //lights();
  
  background(255);
  //d1.run();
 // d2.run();
  d3.run();
  //d4.run();
  // Clear coordinate arrays every frame before plotData populates them
  xCoords.clear();
  yCoords.clear();

  // Push chart space transformation
  pushMatrix();
  translate(chartOffset, 0);
  // drawAxes();
  //  plotData(); // Populates xCoords and yCoords
  popMatrix();

  // Green vertical crosshair line
  stroke(0, 200, 0);
  strokeWeight(.5);
  line(mouseX, 0, mouseX, height);

}

void drawAxes() {
  stroke(200);
  strokeWeight(2);

  // Y-axis
  line(50, 50, 50, height - 50);
  // X-axis
  line(50, height - 50, width - 50, height - 50);

  // Axis Labels
  fill(0);
  textSize(14);
  textAlign(CENTER);
  text("Y-Axis", 25, height / 2);
  text("X-Axis", width / 2, height - 20);
}

void plotData() {
  float[] minMaxX = getMinMax("timeHours");
  float[] minMaxY = getMinMax("derivative");

  float minX = minMaxX[0];
  float maxX = minMaxX[1];
  float minY = minMaxY[0];
  float maxY = minMaxY[1];

  stroke(0, 51, 153);
  strokeWeight(2);
  strokeCap(ROUND);
  noFill();
  beginShape();

  for (int i = 0; i < points.size(); i++) {
    JSONObject p = points.getJSONObject(i);
    float rawX = p.getFloat("timeHours");
    float rawY = p.getFloat("derivative");
    int label = p.getInt("time");

    // Map raw data to screen coordinates
    float mappedX = map(rawX * zoomVal, minX, maxX, 50, width - 50);
    float mappedY = map(rawY, minY, maxY, height - 50, 50);

    // CHANGED: Save the mapped coordinates to track intersections
    xCoords.add(mappedX);
    yCoords.add(mappedY);

    stroke(255, 0, 0);
    strokeWeight(1);
    vertex(mappedX, mappedY);

    textSize(8);
    textAlign(LEFT, CENTER);
    pushMatrix();
    translate(mappedX + 10, height - 40);
    rotate(HALF_PI);
    // Restored text color to make text visible
    fill(0);
    text(label + " " + rawY, 0, 0);
    popMatrix();
    noFill();
  }
  endShape();
}


/*
void drawIntersectionEllipsePlay() {
 // Translate mouseX into chart-space coordinate system
 float targetXInChart = playHeadX - chartOffset;
 
 // Loop through graph coordinates to find where the targetX sits
 for (int i = 0; i < xCoords.size() - 1; i++) {
 float x1 = xCoords.get(i);
 float x2 = xCoords.get(i + 1);
 float y1 = yCoords.get(i);
 float y2 = yCoords.get(i + 1);
 
 // Check if chart-space mouse position sits between these two vertices
 if ((x1 <= targetXInChart && targetXInChart <= x2) || (x2 <= targetXInChart && targetXInChart <= x1)) {
 if (x1 != x2) {
 // Linear interpolation formula to calculate exact Y crossing point
 float intersectingY = y1 + (y2 - y1) * (targetXInChart - x1) / (x2 - x1);
 
 // Draw the tracking ellipse (drawn in screen space, matching crosshair)
 fill(0, 51, 153);
 noStroke();
 ellipse(playHeadX, intersectingY, 12, 12);
 float targetAmp = map(intersectingY, height - 50, 50, 0.0f, 1.0f);
 
 // 3. Apply the calculated amplitude to the Minim oscillator
 wave.setAmplitude(targetAmp);
 // play a note with the myNote object
 // Print the intersection coordinates nearby
 fill(0);
 textSize(12);
 textAlign(LEFT, BOTTOM);
 text("Y: " + nf(intersectingY, 1, 2), mouseX + 10, intersectingY - 10);
 break; // Stop looking once the intersection segment is found
 }
 }
 }
 playHeadX++;
 if (playHeadX > width) playHeadX = 0;
 }
 */
// Helper function to find Min and Max values for scaling
float[] getMinMax(String key) {
  float minVal = MAX_FLOAT;
  float maxVal = MIN_FLOAT;
  for (int i = 0; i < points.size(); i++) {
    float val = points.getJSONObject(i).getFloat(key);
    if (val < minVal) minVal = val;
    if (val > maxVal) maxVal = val;
  }
  return new float[] {minVal, maxVal};
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();

  if (e > 0) {
    zoomVal -= .01 * zoomVal * scaleIntensity;
  } else {
    zoomVal += .01 * zoomVal * scaleIntensity;
  }

  zoomVal = constrain(zoomVal, 0.01, 50);
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == RIGHT) {
      chartOffset += 10 * scaleIntensity;
      //chartOffset = constrain(chartOffset, -width, width); // Fixed syntax error: reassign return value
    } else if (keyCode == LEFT) {
      chartOffset -= 10 * scaleIntensity;
      // chartOffset = constrain(chartOffset, -width, width); // Fixed syntax error: reassign return value
    }

    if (keyCode == SHIFT) {
      scaleIntensity = 10;
    }
  }
}

void keyReleased() {
  if (key == CODED) {
    if (keyCode == SHIFT) {
      scaleIntensity = 1;
    }
  }
}
