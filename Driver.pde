class Driver {
  float playHeadX = width/4;
  ArrayList<Float> xCoords = new ArrayList<>();
  ArrayList<Float> yCoords = new ArrayList<>();
  color c;
  float tone;
  Oscil wave;
  JSONArray points;
  PShape model;
  PVector modelLoc;
  float prevYdata = 0;
  boolean motorOn = false;
  float pumpVal;
  Driver(JSONArray points_, color c_, float tone, PShape model_, PVector modelLoc_, boolean motorOn_) {
    points = points_;
    c = c_;
    wave = new Oscil(tone, 0.0f, Waves.SINE);
    wave.patch(mix);
    model = model_;
    modelLoc = modelLoc_;
    motorOn = motorOn_;
  }

  Driver(JSONArray points_, float tone, PShape model_, PVector modelLoc_, boolean motorOn_) {
    points = points_;
    c = color(int(random(255)), int(random(255)), int(random(255)));
    wave = new Oscil(tone, 0.0f, Waves.SINE);
    wave.patch(mix);
    model = model_;
    modelLoc = modelLoc_;
    motorOn = motorOn_;
  }

  void run() {
    plotData();
    drawIntersectionEllipsePlay();
    // displayModel();
  }

  void displayModel() {
    pushMatrix();
    translate(modelLoc.x, modelLoc.y, -100); // Move to center of screen
    rotateY(0); // Spin the object around the Y-axis

    shape(model); // Display the 3D object
    popMatrix();
  }

  void pumpMotor(float pumpData) {
    
    pumpVal = map(pumpData, 0,1,.5,1.0);
    myPort.write(pumpData*100+ "\n");
  }

  void plotData() {
    float[] minMaxX = getMinMax("timeHours");
    float[] minMaxY = getMinMax("derivative");

    float minX = minMaxX[0];
    float maxX = minMaxX[1];
    float minY = minMaxY[0];
    float maxY = minMaxY[1];

    stroke(c);
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

      stroke(c);
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

          prevYdata = lerp(prevYdata, intersectingY, .25);
          float targetAmp = map(prevYdata, height - 50, 50, 0.0f, 1.0f);

          // 3. Apply the calculated amplitude to the Minim oscillator
          wave.setAmplitude(targetAmp);
          if (motorOn) pumpMotor(targetAmp);

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
}
