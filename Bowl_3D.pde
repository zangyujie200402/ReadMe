import peasy.*;
import peasy.org.apache.commons.math.*;
import peasy.org.apache.commons.math.geometry.*;

PeasyCam cam;

class LowPolyBowl {
  int facetCount;
  float bowlHeight, topWidth, bottomWidth;
  color innerColor, outerColor;
  PVector[] topVertices, bottomVertices;

  LowPolyBowl(float h, float topW, float bottomW, int facets, color innerCol, color outerCol) {
    bowlHeight = h;
    topWidth = topW;
    bottomWidth = bottomW;
    facetCount = facets;
    innerColor = innerCol;
    outerColor = outerCol;
    topVertices = new PVector[facetCount];
    bottomVertices = new PVector[facetCount];
    initializeVertices();
  }

  void initializeVertices() {
    // Top vertices
    for (int i = 0; i < facetCount; i++) {
      float angle = TWO_PI / facetCount * i;
      topVertices[i] = new PVector(cos(angle) * topWidth / 2, sin(angle) * topWidth / 2, -bowlHeight / 2);
    }
    // Bottom vertices
    for (int i = 0; i < facetCount; i++) {
      float angle = TWO_PI / facetCount * i;
      bottomVertices[i] = new PVector(cos(angle) * bottomWidth / 2, sin(angle) * bottomWidth / 2, bowlHeight / 2);
    }
  }

  void display() {
  // Draw sides
  beginShape(TRIANGLES);
  for (int i = 0; i < facetCount; i++) {
    int nextIndex = (i + 1) % facetCount;

    // Side triangles
    fill(lerpColor(outerColor, innerColor, (float)i / (facetCount - 1)));
    vertex(topVertices[i].x, topVertices[i].y, topVertices[i].z);
    vertex(bottomVertices[i].x, bottomVertices[i].y, bottomVertices[i].z);
    vertex(topVertices[nextIndex].x, topVertices[nextIndex].y, topVertices[nextIndex].z);

    vertex(topVertices[nextIndex].x, topVertices[nextIndex].y, topVertices[nextIndex].z);
    vertex(bottomVertices[i].x, bottomVertices[i].y, bottomVertices[i].z);
    vertex(bottomVertices[nextIndex].x, bottomVertices[nextIndex].y, bottomVertices[nextIndex].z);
  }
  endShape(CLOSE);

  // Draw top
  beginShape(TRIANGLES);
  PVector topCenter = new PVector(0, 0, -bowlHeight / 2);
  for (int i = 0; i < facetCount; i++) {
    int nextIndex = (i + 1) % facetCount;
    fill(innerColor);
    vertex(topVertices[i].x, topVertices[i].y, topVertices[i].z);
    vertex(topVertices[nextIndex].x, topVertices[nextIndex].y, topVertices[nextIndex].z);
    vertex(topCenter.x, topCenter.y, topCenter.z);
  }
  endShape(CLOSE);
}


}

LowPolyBowl bowl;

void setup() {
  size(800, 600, P3D);
  cam = new PeasyCam(this, 2000);
  bowl = new LowPolyBowl(20, 200, 150, 20, color(100, 1, 1), color(250, 250, 255));
}

void draw() {
  background(255);
  lights();
  bowl.display();
}
