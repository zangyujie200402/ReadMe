int numColumns;
int numRows;
int[] columnWidths;
int[] rowHeights;
color[] customColors;
int xStart;
int yStart;
int frameCount = 0;

void setup() {
  size(640, 640);
  frameRate(30);  
  noLoop();
}

void draw() {
  if (frameCount < 100) {  
    background(255);
    int x = xStart;
    for (int i = 0; i < numColumns; i++) {
      int y = yStart;
      for (int j = 0; j < numRows; j++) {
        int randomColorIndex = int(random(customColors.length));
        fill(customColors[randomColorIndex]);
        rect(x, y, columnWidths[i], rowHeights[j]);
        y += rowHeights[j];
      }
      x += columnWidths[i];
    }
    saveFrame("output/frame" + frameCount + ".png");  
    frameCount++;
  } else {
    noLoop();  
  }
}

void mousePressed() {
  changeColors();
  redraw();
}

void changeColors() {
  numColumns = int(random(4, 7));
  numRows = int(random(4, 7));

  columnWidths = calculateSizes(numColumns, width - 40, 60, 160);
  rowHeights = calculateSizes(numRows, height - 40, 60, 160);

  customColors = new color[]{color(255, 0, 0), color(0, 0, 255), color(255), color(255, 255, 0)};
  
  xStart = 20;
  yStart = 20;
}

int[] calculateSizes(int numElements, int totalSize, int minSize, int maxSize) {
  int[] sizes = new int[numElements];
  int remainingSize = totalSize;
  for (int i = 0; i < numElements - 1; i++) {
    int size = int(random(minSize, min(remainingSize - minSize * (numElements - i - 1), maxSize)));
    sizes[i] = size;
    remainingSize -= size;
  }
  sizes[numElements - 1] = remainingSize;
  return sizes;
}
