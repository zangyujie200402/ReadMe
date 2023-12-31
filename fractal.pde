ArrayList<Agent> agents;
float minX = -2.5;
float maxX = 1;
float minY = -1;
float maxY = 1;
float zoom = 1;
float panX = 0;
float panY = 0;
final int Y_AXIS = 1; // Define Y_AXIS as 1
final int X_AXIS = 1; 

void setGradient(int x, int y, float w, float h, color c1, color c2, int axis) {
  noFill();

  if (axis == Y_AXIS) {
    // 上到下的渐变
    for (int i = y; i <= y + h; i++) {
      float inter = map(i, y, y + h, 0, 1);
      color c = lerpColor(c1, c2, inter);
      stroke(c);
      line(x, i, x + w, i);
    }
  } else if (axis == X_AXIS) {
    // 左到右的渐变
    for (int i = x; i <= x + w; i++) {
      float inter = map(i, x, x + w, 0, 1);
      color c = lerpColor(c1, c2, inter);
      stroke(c);
      line(i, y, i, y + h);
    }
  }
}

void setup() {
  size(800, 800);
  colorMode(HSB, 255);
  agents = new ArrayList<Agent>();

  // 设置蓝色渐变背景
  setGradient(0, 0, width, height, color(0, 100, 255), color(120, 100, 255), Y_AXIS);

  for (int i = 0; i <2000; i++) {
    agents.add(new Agent());
  }
}



void draw() {
  loadPixels();
  drawMandelbrot();
  updatePixels();
  drawAgents();
  
  saveFrame("frame-####.png");
}

void drawMandelbrot() {
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      float a = map(x, 0, width, minX / zoom - panX, maxX / zoom - panX);
      float b = map(y, 0, height, minY / zoom - panY, maxY / zoom - panY);
      ComplexNumber c = new ComplexNumber(a, b);
      ComplexNumber z = new ComplexNumber(0, 0);

      int n = 0;
      int maxIterations = 100;
      while (n < maxIterations) {
        z = z.square().add(c);
        if (z.abs() > 16) {
          break;
        }
        n++;
      }

      float norm = map(sqrt(n), 0, sqrt(maxIterations), 0, 1);
      float hue = (200 + n * 8) % 255;
      float saturation = 150 + n % 105;
      float brightness = n < maxIterations ? 255 : 0;
      pixels[x + y * width] = color(hue, saturation, brightness);
    }
  }
}

void drawAgents() {
  for (Agent agent : agents) {
    agent.update();
    agent.display();
    
    // 确保粒子的坐标在有效范围内
    if (agent.x >= 0 && agent.x < width && agent.y >= 0 && agent.y < height) {
      int col = pixels[int(constrain(agent.x, 0, width - 1)) + int(constrain(agent.y, 0, height - 1)) * width];
      float agentHue = hue(col);
      float agentSaturation = saturation(col);
      agent.setColor(agentHue, agentSaturation);
      agent.leaveTrail(); // 让粒子在曼德博集上留下轨迹
      agent.followEdge(); // 使粒子跟随曼德博集的边缘滑行
    }
  }
}



void mousePressed() {
  for (Agent agent : agents) {
    agent.attract(mouseX, mouseY);
  }
}

class Agent {
  float x, y;
  float angle;
  float speed;

  Agent() {
    x = random(width);
    y = random(height);
    angle = random(TWO_PI);
    speed = random(1, 3);
  }

  void update() {
    x += cos(angle) * speed;
    y += sin(angle) * speed;
    angle += random(-0.1, 0.1);
    if (x < 0 || x > width) angle = PI - angle;
    if (y < 0 || y > height) angle = -angle;
  }

  void display() {
    fill(255);
    noStroke();
    ellipse(x, y, 5, 5);
  }

  void attract(float targetX, float targetY) {
    angle = atan2(targetY - y, targetX - x);
  }

  void setColor(float h, float s) {
    fill(h, s, 255);
  }

  void leaveTrail() {
    // 在当前位置绘制一个小点，留下轨迹
    stroke(255, 100);
    point(x, y);
  }

  void followEdge() {
    // 获取周围九个像素的颜色
    int col = pixels[int(constrain(x, 0, width - 1)) + int(constrain(y, 0, height - 1)) * width];
    int[] neighborCols = new int[9];
    neighborCols[0] = col;
    neighborCols[1] = pixels[int(constrain(x - 1, 0, width - 1)) + int(constrain(y - 1, 0, height - 1)) * width];
    neighborCols[2] = pixels[int(constrain(x, 0, width - 1)) + int(constrain(y - 1, 0, height - 1)) * width];
    neighborCols[3] = pixels[int(constrain(x + 1, 0, width - 1)) + int(constrain(y - 1, 0, height - 1)) * width];
    neighborCols[4] = pixels[int(constrain(x - 1, 0, width - 1)) + int(constrain(y, 0, height - 1)) * width];
    neighborCols[5] = pixels[int(constrain(x + 1, 0, width - 1)) + int(constrain(y, 0, height - 1)) * width];
    neighborCols[6] = pixels[int(constrain(x - 1, 0, width - 1)) + int(constrain(y + 1, 0, height - 1)) * width];
    neighborCols[7] = pixels[int(constrain(x, 0, width - 1)) + int(constrain(y + 1, 0, height - 1)) * width];
    neighborCols[8] = pixels[int(constrain(x + 1, 0, width - 1)) + int(constrain(y + 1, 0, height - 1)) * width];

    // 计算颜色差异，找到颜色变化最大的方向
    float maxDiff = 0;
    int maxIndex = 0;
    for (int i = 1; i < 9; i++) {
      float diff = brightness(col) - brightness(neighborCols[i]);
      if (diff > maxDiff) {
        maxDiff = diff;
        maxIndex = i;
      }
    }

    // 根据颜色变化最大的方向调整粒子的角度
    switch (maxIndex) {
      case 1:
        angle = PI + QUARTER_PI;
        break;
      case 2:
        angle = PI;
        break;
      case 3:
        angle = PI - QUARTER_PI;
        break;
      case 4:
        angle = HALF_PI;
        break;
      case 5:
        angle = -HALF_PI;
        break;
      case 6:
        angle = -QUARTER_PI;
        break;
      case 7:
        angle = 0;
        break;
      case 8:
        angle = TWO_PI - QUARTER_PI;
        break;
    }
  }
}



class ComplexNumber {
  float real;
  float imaginary;

  ComplexNumber(float r, float i) {
    real = r;
    imaginary = i;
  }

  ComplexNumber square() {
    float newReal = real * real - imaginary * imaginary;
    float newImaginary = 2 * real * imaginary;
    return new ComplexNumber(newReal, newImaginary);
  }

  ComplexNumber add(ComplexNumber c) {
    return new ComplexNumber(real + c.real, imaginary + c.imaginary);
  }

  float abs() {
    return sqrt(real * real + imaginary * imaginary);
  }
}
