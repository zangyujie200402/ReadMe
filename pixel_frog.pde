PImage frogImage;
int pixelSize = 10; // 定义像素块的大小
int fadeInFrames = 60; // 定义淡入效果的帧数
float angle = 0; // 初始化角度
float angleStep = TWO_PI / 120; // 每帧角度增加值
int loopFrames = 250; // 定义循环的总帧数，包括淡入和动态效果
float maxOffset = 5; // 最大像素偏移

void setup() {
  size(901, 768); // 设置画布大小以适应青蛙图像的尺寸
  frogImage = loadImage("image.png"); // 加载青蛙图像
  frogImage.resize(width / pixelSize, height / pixelSize); // 将图像缩放为像素化处理的大小
  
  noSmooth(); // 关闭图形平滑处理，使像素化效果更明显
  imageMode(CENTER);
}

void draw() {
  background(255); // 使用白色背景
  translate(width / 2 - frogImage.width * pixelSize / 2, height / 2 - frogImage.height * pixelSize / 2);
  
  // 如果仍在淡入阶段，则透明度逐渐增加
  if (frameCount <= fadeInFrames) {
    float alpha = map(frameCount, 0, fadeInFrames, 0, 255);
    drawPixelsWithAlpha(alpha);
  } else { // 淡入完成后，逐渐开始动画
    if (frameCount <= loopFrames) {
      // 在淡入完成后开始应用动态效果
      float dynamicOffset = map(frameCount, fadeInFrames, loopFrames, 0, maxOffset);
      angle += angleStep;
      drawPixelsWithOffset(dynamicOffset);
    }
  }
  
  // 保存帧
  saveFrame("frames/frame-####.png");
  
  // 当保存足够的帧后停止循环
  if (frameCount >= loopFrames) {
    noLoop();
  }
}

// 用透明度绘制像素
void drawPixelsWithAlpha(float alpha) {
  for (int i = 0; i < frogImage.width; i++) {
    for (int j = 0; j < frogImage.height; j++) {
      color c = frogImage.get(i, j);
      fill(red(c), green(c), blue(c), alpha);
      rect(i * pixelSize, j * pixelSize, pixelSize, pixelSize);
    }
  }
}

// 用偏移绘制像素
void drawPixelsWithOffset(float offset) {
  for (int i = 0; i < frogImage.width; i++) {
    for (int j = 0; j < frogImage.height; j++) {
      color c = frogImage.get(i, j);
      fill(c);
      float dynamicOffset = sin(angle + i * 0.1 + j * 0.1) * offset;
      rect(i * pixelSize + dynamicOffset, j * pixelSize + dynamicOffset, pixelSize, pixelSize);
    }
  }
}
