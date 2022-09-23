////////////////////////////////////////////////////////////////////////
class Environment {
  ////////////////////////////////////////////////////////////////////////
  class AgentInfo extends Agent {
    // Position of the agent with x in [0, width[ and y in [0, height[
    public PVector position;
    // Orientation of the agent where 2*PI is a full turn
    public float orientation;
    
    AgentInfo(Environment env_, int id_) {
      // Init super class (Agent)
      super(env_, id_);
      // Agent spawn with a random location/orientation and empty inventory
      position = new PVector(random(0.5, width - 0.5), random(0.5, height - 0.5));
      orientation = random(0, 2.0*PI);
    }
  }
  ////////////////////////////////////////////////////////////////////////
  
  
  
  // List containing all the agents
  private ArrayList<AgentInfo> agentList;
  // Grid containing the world
  private int[][] mapField;
  // Grid containing "to home" markers
  private float[][] toHomeField;
  // Grid containing "to food" markers
  private float[][] toFoodField;
  
  
  private float[][] newToHomeField = new float[GRID_SIZE][GRID_SIZE];
  private float[][] newToFoodField = new float[GRID_SIZE][GRID_SIZE];
  
  
  
  Environment() {
    // Init the list with all the agents
    agentList = new ArrayList<AgentInfo>();
    for (int i = 0; i < NB_AGENTS; i++) {
      agentList.add(new AgentInfo(this, i));
    }

    // Field containing food (N), home (-1), and walls (-2)
    mapField = new int[GRID_SIZE][GRID_SIZE];
    for (int x = 0; x < GRID_SIZE; x++) {
      for (int y = 0; y < GRID_SIZE; y++) {
        mapField[x][y] = 0;
      }
    }

    // Field containing "to home" markers
    toHomeField = new float[GRID_SIZE][GRID_SIZE];
    for (int x = 0; x < GRID_SIZE; x++) {
      for (int y = 0; y < GRID_SIZE; y++) {
        toHomeField[x][y] = 0;
      }
    }

    // Field containing "to food" markers
    toFoodField = new float[GRID_SIZE][GRID_SIZE];
    for (int x = 0; x < GRID_SIZE; x++) {
      for (int y = 0; y < GRID_SIZE; y++) {
        toFoodField[x][y] = 0;
      }
    }
  }



  ////// ACTIONS //////
  public void tryMove(Agent agent) {
    PVector agentPos = agentList.get(agent.id).position;
    float agentOri = agentList.get(agent.id).orientation;
    PVector nextPos = agentPos.copy().add((new PVector(width/GRID_SIZE, 0)).rotate(agentOri));

    int gridX = int(GRID_SIZE*nextPos.x/width);
    int gridY = int(GRID_SIZE*nextPos.y/height);
    if (nextPos.x < 0 || nextPos.x >= width || nextPos.y < 0 || nextPos.y >= height || mapField[gridX][gridY] == -2) {
      agentList.get(agent.id).orientation += random(PI/2.0, 3.0*PI/2.0);
    } else {
      agentList.get(agent.id).position = nextPos;
    }
  }


  public void tryTurnRandom(Agent agent) {
    agentList.get(agent.id).orientation += random(-SENSOR_ANGLE, SENSOR_ANGLE);
  }

  public void tryTurnLeft(Agent agent) {
    agentList.get(agent.id).orientation += -SENSOR_ANGLE;
  }

  public void tryTurnRight(Agent agent) {
    agentList.get(agent.id).orientation += SENSOR_ANGLE;
  }

  public void tryTurnAround(Agent agent) {
    agentList.get(agent.id).orientation += PI;
  }


  public void tryDepositHomeMarker(Agent agent, float intensity) {
    int gridX = int(GRID_SIZE*agentList.get(agent.id).position.x/width);
    int gridY = int(GRID_SIZE*agentList.get(agent.id).position.y/height);
    toHomeField[gridX][gridY] += intensity;
  }


  public void tryDepositFoodMarker(Agent agent, float intensity) {
    int gridX = int(GRID_SIZE*agentList.get(agent.id).position.x/width);
    int gridY = int(GRID_SIZE*agentList.get(agent.id).position.y/height);
    toFoodField[gridX][gridY] += intensity;
  }
  ////// - //////

  

  // Update an agent perceptions
  private void updateAgentPerception(Agent agent) {
    PVector agentPos = agentList.get(agent.id).position;
    float agentOri = agentList.get(agent.id).orientation;


    // Update cell sensor
    {
      int gridX = int(GRID_SIZE*agentPos.x/width);
      int gridY = int(GRID_SIZE*agentPos.y/height);
      agentList.get(agent.id).sensorCell = mapField[gridX][gridY];
    }


    // Left sensor
    {
      PVector tempPos = agentPos.copy().add((new PVector((2.0*DIFF_RANGE + 1)*width/GRID_SIZE, 0)).rotate(agentOri - SENSOR_ANGLE));
      int gridX = int(GRID_SIZE*tempPos.x/width);
      int gridY = int(GRID_SIZE*tempPos.y/height);

      agentList.get(agent.id).sensorFoodLeft = 0;
      agentList.get(agent.id).sensorHomeLeft = 0;
      if (!(tempPos.x < 0 || tempPos.x >= width || tempPos.y < 0 || tempPos.y >= height || mapField[gridX][gridY] == -2)) {
        agentList.get(agent.id).sensorFoodLeft = newToFoodField[gridX][gridY];
        agentList.get(agent.id).sensorHomeLeft = newToHomeField[gridX][gridY];
      }
    }


    // Front sensor
    {
      PVector tempPos = agentPos.copy().add((new PVector((2.0*DIFF_RANGE + 1)*width/GRID_SIZE, 0)).rotate(agentOri));
      int gridX = int(GRID_SIZE*tempPos.x/width);
      int gridY = int(GRID_SIZE*tempPos.y/height);

      agentList.get(agent.id).sensorFoodFront = 0;
      agentList.get(agent.id).sensorHomeFront = 0;
      if (!(tempPos.x < 0 || tempPos.x >= width || tempPos.y < 0 || tempPos.y >= height || mapField[gridX][gridY] == -2)) {
        agentList.get(agent.id).sensorFoodFront = newToFoodField[gridX][gridY];
        agentList.get(agent.id).sensorHomeFront = newToHomeField[gridX][gridY];
      }
    }


    // Right sensor
    {
      PVector tempPos = agentPos.copy().add((new PVector((2.0*DIFF_RANGE + 1)*width/GRID_SIZE, 0)).rotate(agentOri + SENSOR_ANGLE));
      int gridX = int(GRID_SIZE*tempPos.x/width);
      int gridY = int(GRID_SIZE*tempPos.y/height);

      agentList.get(agent.id).sensorFoodRight = 0;
      agentList.get(agent.id).sensorHomeRight = 0;
      if (!(tempPos.x < 0 || tempPos.x >= width || tempPos.y < 0 || tempPos.y >= height || mapField[gridX][gridY] == -2)) {
        agentList.get(agent.id).sensorFoodRight = newToFoodField[gridX][gridY];
        agentList.get(agent.id).sensorHomeRight = newToHomeField[gridX][gridY];
      }
    }
  }



  // Update environment, agents perceptions, and make them do one step + display the environment
  public void step(boolean displayDensity) {
    for (int x = 0; x < GRID_SIZE; x++) {
      for (int y = 0; y < GRID_SIZE; y++) {
        toHomeField[x][y] *= (1 - EVAP_RATE);
        toFoodField[x][y] *= (1 - EVAP_RATE);
        newToHomeField[x][y] = 0;
        newToFoodField[x][y] = 0;
        
        // Compute evaporation and diffusion
        for (int k = -DIFF_RANGE; k <= DIFF_RANGE; k++) {
          for (int l = -DIFF_RANGE; l <= DIFF_RANGE; l++) {
            if (x + k >= 0 && x + k < GRID_SIZE && y + l >= 0 && y + l < GRID_SIZE) {
              newToHomeField[x][y] += pow(toHomeField[x + k][y + l]/(2.0*DIFF_RANGE + 1), 2);
              newToFoodField[x][y] += pow(toFoodField[x + k][y + l]/(2.0*DIFF_RANGE + 1), 2);
              
              if (mapField[x + k][y + l] == -1) {
                newToHomeField[x][y] += 9999;
              } else if (mapField[x + k][y + l] > 0) {
                newToFoodField[x][y] += 9999;
              }
            }
          }
        }
        
        if (toHomeField[x][y] < FIELD_MIN) toHomeField[x][y] = 0;
        if (toFoodField[x][y] < FIELD_MIN) toFoodField[x][y] = 0;

        noStroke();
        if (!displayDensity) {
          fill(toHomeField[x][y]*171 + 33, toFoodField[x][y]*171 + 33, max(toHomeField[x][y], toFoodField[x][y])*171 + 33);
        } else {
          fill(33, 33, 33, 33);
        }

        if (mapField[x][y] > 0) {
          strokeWeight(width / GRID_SIZE / 4.0);
          stroke(33, 33, 33);
          fill(33, 171*mapField[x][y] + 33, 171*mapField[x][y] + 33);
        }
        if (mapField[x][y] == -1) {
          strokeWeight(width / GRID_SIZE / 4.0);
          stroke(33, 33, 33);
          fill(204, 33, 204);
        }
        if (mapField[x][y] == -2) {
          strokeWeight(width / GRID_SIZE / 4.0);
          stroke(204, 204, 204);
          fill(33, 33, 33);
        } 

        rect(x * width / GRID_SIZE, y * height / GRID_SIZE, width / GRID_SIZE, height / GRID_SIZE);
      }
    }
        
    for (int i = 0; i < NB_AGENTS; i++) {
      updateAgentPerception(agentList.get(i));
      agentList.get(i).step();

      if (displayDensity) {
        int gridX = int(GRID_SIZE*agentList.get(i).position.x/width);
        int gridY = int(GRID_SIZE*agentList.get(i).position.y/width);

        noStroke();
        fill(204, 204, 204, 33);
        rect(gridX * width / GRID_SIZE, gridY * height / GRID_SIZE, width / GRID_SIZE, height / GRID_SIZE);
      }      
    }
  }
}
////////////////////////////////////////////////////////////////////////
