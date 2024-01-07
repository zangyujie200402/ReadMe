import javax.swing.JFileChooser;
import javax.swing.filechooser.FileNameExtensionFilter;
import com.thomasdiewald.pixelflow.java.DwPixelFlow;
import com.thomasdiewald.pixelflow.java.fluid.DwFluid2D;
import controlP5.*;

ControlP5 cp5;
Slider velocityDissipationSlider, densityDissipationSlider, inkTransparencySlider, brushSizeSlider;

Knob brushIntensityKnob;

DwFluid2D fluid;
DwPixelFlow context;
PGraphics2D pg_fluid;
PImage img;
Button resetButton, saveButton;
color brushColor;
float brushSize = 20;

void setup() {
    size(1280, 800, P2D);
    selectInput("Select an image file:", "fileSelected");

    context = new DwPixelFlow(this);
    context.print();
    context.printGL();

    fluid = new DwFluid2D(context, width, height, 1);
    fluid.param.dissipation_velocity = 0.70f;
    fluid.param.dissipation_density = 0.99f;

    brushColor = color(0, 0, 0, 150); // Black, semi-transparent
    brushSize = 50;

    pg_fluid = (PGraphics2D) createGraphics(width, height, P2D);

    resetButton = new Button(10, 10, 100, 30, "Reset");
    saveButton = new Button(120, 10, 100, 30, "Save Image");

    frameRate(60);

    cp5 = new ControlP5(this);

    velocityDissipationSlider = cp5.addSlider("velocityDissipation")
                                   .setPosition(10, 50)
                                   .setSize(100, 20)
                                   .setRange(0, 1)
                                   .setValue(0.70f);

    densityDissipationSlider = cp5.addSlider("densityDissipation")
                                   .setPosition(120, 50)
                                   .setSize(100, 20)
                                   .setRange(0, 1)
                                   .setValue(0.99f);
    
    brushIntensityKnob = cp5.addKnob("brushIntensity")
                            .setPosition(360, 40)
                            .setRange(0, 255)
                            .setValue(150)
                            .setRadius(30)
                            .setDragDirection(Knob.VERTICAL); 
    
    brushSizeSlider = cp5.addSlider("brushSize")
                          .setPosition(230, 50)
                          .setSize(100, 20)
                          .setRange(10, 100)
                          .setValue(20);

    inkTransparencySlider = cp5.addSlider("inkTransparency ")
                               .setPosition(450, 50)
                               .setSize(100, 20)
                               .setRange(0, 255) 
                               .setValue(150); 
    
                    
}

void draw() {
    if (img != null) {
        fluid.param.dissipation_velocity = velocityDissipationSlider.getValue();
        fluid.param.dissipation_density = densityDissipationSlider.getValue();
        brushSize = brushSizeSlider.getValue();
        brushColor = color(brushIntensityKnob.getValue());

        fluid.update();

        pg_fluid.beginDraw();
        pg_fluid.background(0);
        pg_fluid.image(img, 0, 0);
        pg_fluid.endDraw();

        fluid.renderFluidTextures(pg_fluid, 0);

        image(pg_fluid, 0, 0);
    }

    resetButton.update();
    saveButton.update();

    resetButton.display();
    saveButton.display();

    if (resetButton.pressed()) {
        resetFluid();
    }
    if (saveButton.pressed()) {
        saveImage();
    }

    if (!isMouseOverControl() && mousePressed) {
        float px = mouseX;
        float py = height - mouseY;
        float vx = (mouseX - pmouseX) * +15;
        float vy = (mouseY - pmouseY) * -15;
        
        // 获取透明度值
        float transparency = inkTransparencySlider.getValue();
        brushColor = color(red(brushColor), green(brushColor), blue(brushColor), transparency);

        fluid.addVelocity(px, py, brushSize, vx, vy);
        fluid.addDensity(px, py, brushSize, red(brushColor)/255, green(brushColor)/255, blue(brushColor)/255, alpha(brushColor)/255);
    }
}

void resetFluid() {
    fluid.reset();
}

void saveImage() {
    String timestamp = year() + nf(month(), 2) + nf(day(), 2) + "_" + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2);
    saveFrame("image_" + timestamp + ".png");
}

void fileSelected(File selection) {
    if (selection == null) {
        println("Window was closed or the user hit cancel.");
    } else {
        img = loadImage(selection.getAbsolutePath());
        img.resize(width, height);
        convertToGrayscale(img); // 转换为灰白风格
    }
}

void convertToGrayscale(PImage img) {
    img.loadPixels();
    for (int i = 0; i < img.pixels.length; i++) {
        int c = img.pixels[i];
        int gray = int((red(c) + green(c) + blue(c)) / 3);
        img.pixels[i] = color(gray);
    }
    img.updatePixels();
}


class Button {
  float x, y, w, h;
  String text;
  boolean isOver = false;

  Button(float x, float y, float w, float h, String text) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.text = text;
  }
    
  void display() {
    fill(isOver ? color(200, 200, 0) : color(200));
    rect(x, y, w, h);
    fill(0);
    textAlign(CENTER, CENTER);
    text(text, x + w * 0.5, y + h * 0.5);
  }

  boolean overRect() {
    return mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h;
  }

  void update() {
    isOver = overRect();
  }

  boolean pressed() {
    return isOver && mousePressed;
  }
}

boolean isMouseOverControl() {
    return cp5.isMouseOver();
}
