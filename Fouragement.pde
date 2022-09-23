import java.security.*;

// ENVIRONMENT PARAMETERS
final int GRID_SIZE = 100;
final int NB_AGENTS = 500;
final float EVAP_RATE = 0.05;
final int DIFF_RANGE = 1;
final float FIELD_MIN = 0.01;
final float SENSOR_ANGLE = 3.1415/3.0;
// AGENTS PARAMETERS
final float MAX_STEP = 1000.0;

// Environment instance
Environment env;

boolean pressX = false;

void setup() {
  // Define screen size and refresh rate
  size(800, 800);

  // Verify the parameters
  if (GRID_SIZE < 10) throw new InvalidParameterException("GRID_SIZE is to low, lower bound is: " + 10);
  if (GRID_SIZE > min(width, height)) throw new InvalidParameterException("GRID_SIZE is to hight, upper bound is: " + min(width, height));
  if (NB_AGENTS < 1) throw new InvalidParameterException("NB_AGENTS is to low, lower bound is: " + 1);

  // Create the environment
  env = new Environment();
}


void draw() {
  env.step(keyPressed && pressX);
}


// To draw on the map
void keyPressed() {
  int value = 0;
  pressX = false;
  switch (key) {
    case '0':
      value = -2;
      break;
    case '1':
      value = -1;
      break;
    case '2':
      value = 0;
      break;
    case '3':
      value = 1;
      break;
    case 'x':
      pressX = true;
      break;
    case 'X':
      pressX = true;
      break;
  }
  
  int gridX = int(GRID_SIZE*mouseX/width);
  int gridY = int(GRID_SIZE*mouseY/height);
  
  if (gridX >= 0 && gridX < GRID_SIZE && gridY >= 0 && gridY < GRID_SIZE) {
    env.mapField[gridX][gridY] = value;
    if (gridX + 1 < GRID_SIZE) env.mapField[gridX + 1][gridY] = value;
    if (gridX - 1 > -1) env.mapField[gridX - 1][gridY] = value;
    if (gridY + 1 < GRID_SIZE) env.mapField[gridX][gridY + 1] = value;
    if (gridY - 1 > -1) env.mapField[gridX][gridY - 1] = value;
  }
}
