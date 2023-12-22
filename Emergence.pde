Agent[] agents;
int numAgents = 150;
float maxForce = 0.05;

void setup() {
  size(800, 600);
  agents = new Agent[numAgents];
  for (int i = 0; i < numAgents; i++) {
    float maxSpeed = random(1, 4);
    float perceptionRadius = random(50, 150);
    agents[i] = new Agent(random(width), random(height), maxSpeed, perceptionRadius);
  }
}

void draw() {
  drawGradientBackground(); // 绘制渐变背景
  for (Agent a : agents) {
    a.update(agents);
    a.display();
  }
  
  saveFrame("frame-####.png"); 
}

void drawGradientBackground() {
  for (int y = 0; y < height; y++) {
    float inter = map(y, 0, height, 0, 1);
    int c = lerpColor(color(255, 229, 204), color(204, 229, 255), inter); // 更浅的颜色
    stroke(c);
    line(0, y, width, y);
  }
}

class Agent {
  PVector position, velocity, acceleration;
  float perceptionRadius, size;
  float maxSpeed;
  int agentColor;

  Agent(float x, float y, float maxSpeed, float perceptionRadius) {
    position = new PVector(x, y);
    velocity = PVector.random2D();
    acceleration = new PVector();
    this.maxSpeed = maxSpeed;
    this.perceptionRadius = perceptionRadius;
    size = random(4, 12); // 初始随机大小
    agentColor = color(random(255), random(255), random(255), 200);
  }

  void applyForce(PVector force) {
    acceleration.add(force);
  }

  void update(Agent[] agents) {
    PVector alignment = align(agents);
    PVector cohesion = cohere(agents);
    PVector separation = separate(agents);

    applyForce(alignment);
    applyForce(cohesion);
    applyForce(separation);

    velocity.add(acceleration);
    velocity.limit(maxSpeed); // 限制最大速度
    position.add(velocity);
    acceleration.mult(0);

    edges();
  }

  void display() {
    size = random(4, 12); // 每次绘制时随机大小
    noStroke();
    fill(agentColor);
    ellipse(position.x, position.y, size, size);
  }

  PVector align(Agent[] agents) {
    PVector steer = new PVector();
    int total = 0;
    for (Agent other : agents) {
      float d = PVector.dist(position, other.position);
      if (other != this && d < perceptionRadius) {
        steer.add(other.velocity);
        total++;
      }
    }
    if (total > 0) {
      steer.div(total);
      steer.setMag(maxSpeed);
      steer.sub(velocity);
      steer.limit(maxForce);
    }
    return steer;
  }

  PVector cohere(Agent[] agents) {
    PVector steer = new PVector();
    int total = 0;
    for (Agent other : agents) {
      float d = PVector.dist(position, other.position);
      if (other != this && d < perceptionRadius) {
        steer.add(other.position);
        total++;
      }
    }
    if (total > 0) {
      steer.div(total);
      steer.sub(position);
      steer.setMag(maxSpeed);
      steer.sub(velocity);
      steer.limit(maxForce);
    }
    return steer;
  }

  PVector separate(Agent[] agents) {
    PVector steer = new PVector();
    int total = 0;
    for (Agent other : agents) {
      float d = PVector.dist(position, other.position);
      if (other != this && d < perceptionRadius) {
        PVector diff = PVector.sub(position, other.position);
        diff.normalize();
        diff.div(d);
        steer.add(diff);
        total++;
      }
    }
    if (total > 0) {
      steer.div(total);
      steer.setMag(maxSpeed);
      steer.sub(velocity);
      steer.limit(maxForce);
    }
    return steer;
  }

  void edges() {
    if (position.x > width) position.x = 0;
    if (position.x < 0) position.x = width;
    if (position.y > height) position.y = 0;
    if (position.y < 0) position.y = height;
  }
}
