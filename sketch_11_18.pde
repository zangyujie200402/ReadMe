void setup() {
  size(600, 600);
  background(255);
}

void draw() {
  drawWall289(mouseX, mouseY);
  saveFrame();
}

void drawWall289(float mouseX, float mouseY) {
  stroke(0);
  
  for (int i = 0; i < 24; i++) {
    float x = width / 2;
    float y = map(i, 0, 23, 0, height);
    line(x, 0, x, height);
  }

  for (int i = 0; i < 12; i++) {
    float x = map(i, 0, 11, 0, width);
    float y = height / 2;
    line(0, y, width, y);
  }

  for (int i = 0; i < 12; i++) {
    float angle = radians(i * (360.0 / 12));
    float x1 = width / 2;
    float y1 = height / 2;
    float x2 = mouseX + (width / 2) * cos(angle);
    float y2 = mouseY + (height / 2) * sin(angle);
    line(x1, y1, x2, y2);
  }
}

void mousePressed() {
  background(255);  
}
