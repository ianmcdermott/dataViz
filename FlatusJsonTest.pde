JSONObject json;
JSONArray points;

float zoomVal = 1;
float chartOffset = 0;
float scaleIntensity = 1;
ArrayList<Float> xCoords, yCoords = new ArrayList<>();

void setup() {
  size(2000, 1000);
  // Load JSON file from the data folder
  json = loadJSONObject("data/dump_1782907724291_1782821998.json");
  points = json.getJSONArray("sensorData");

  rectMode(CENTER);
    float[] minMaxX = getMinMax("timeHours");
  float[] minMaxY = getMinMax("derivative");

  float minX = minMaxX[0];
  float maxX = minMaxX[1];
  float minY = minMaxY[0];
  float maxY = minMaxY[1];

   for (int i = 0; i < points.size(); i++) {
    JSONObject p = points.getJSONObject(i);
    float rawX = p.getFloat("timeHours");
    float rawY = p.getFloat("derivative");
    int label = p.getInt("time");

    // Map raw data to screen coordinates
    float mappedX = map(rawX*zoomVal, minX, maxX, 50, width - 50);
    float mappedY = map(rawY, minY, maxY, height - 50, 50);
   }
}

void draw() {
  background(255);

  stroke(0, 200, 0);
  strokeWeight(.5);
  line(mouseX, 0, mouseX, height);
  text("hi", mouseX, mouseY);

  pushMatrix();
  translate(chartOffset, 0);
  drawAxes();
  plotData();
  popMatrix();
  
   // ArrayList<Float> intersections = getVerticalIntersections(mouseX, xCoords, yCoords, numVertices);

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




  //fill(0, 102, 255);
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
    float mappedX = map(rawX*zoomVal, minX, maxX, 50, width - 50);
    float mappedY = map(rawY, minY, maxY, height - 50, 50);

    stroke(255, 0, 0);        // Set line color to black
    strokeWeight(1);  // Set line thickness
    vertex(mappedX, mappedY);

    // Label object's key
    //fill(0);
    textSize(8);
    textAlign(LEFT, CENTER);
    pushMatrix();
    translate(mappedX + 10, height - 40);
    rotate(HALF_PI);
    text(label + " " + rawY, 0, 0);
    popMatrix();
  }
  endShape();
}

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
  float e = event.getCount(); // Returns 1.0 (scroll down) or -1.0 (scroll up)

  if (e > 0) {
    zoomVal -= .01*zoomVal*scaleIntensity; // Decrease variable
  } else {
    zoomVal += .01*zoomVal*scaleIntensity; // Increase variable
  }

  zoomVal = constrain(zoomVal, 0.01, 50);
}
void keyPressed() {
  if (key == CODED) {
    if (keyCode == RIGHT) {
      chartOffset+=10*scaleIntensity; // Increases the value by 1
      constrain(chartOffset, 50, width);
    } else if (keyCode == LEFT) {
      chartOffset-=10*scaleIntensity; // Decreases the value by 1
      constrain(chartOffset, 50, width);
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

// Function to calculate all Y-values where a vertical line intersects the shape
ArrayList<Float> getVerticalIntersections(float xLine, float[] polyX, float[] polyY, int numVerts) {
  ArrayList<Float> hits = new ArrayList<Float>();
  
  for (int i = 0; i < numVerts; i++) {
    // Get the current edge endpoints
    float x1 = polyX[i];
    float y1 = polyY[i];
    float x2 = polyX[(i + 1) % numVerts]; // Wraps back to the first vertex
    float y2 = polyY[(i + 1) % numVerts];
    
    // Check if the vertical line's X falls strictly between the edge's X endpoints
    if ((x1 <= xLine && xLine <= x2) || (x2 <= xLine && xLine <= x1)) {
      
      // Calculate Y where the vertical line crosses this specific edge
      // Using linear interpolation formula to solve for Y:
      if (x1 != x2) { // Prevent division by zero for perfectly vertical edges
        float yIntersect = y1 + (y2 - y1) * (xLine - x1) / (x2 - x1);
        hits.add(yIntersect);
      }
    }
  }
  return hits;
}
