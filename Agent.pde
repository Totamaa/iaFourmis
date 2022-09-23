////////////////////////////////////////////////////////////////////////
class Agent {
  public Environment env;
  public int id;
  
  public float sensorFoodLeft;
  public float sensorFoodFront;
  public float sensorFoodRight;
  public float sensorHomeLeft;
  public float sensorHomeFront;
  public float sensorHomeRight;
  public float sensorCell;
  public float explore;
  public int etat; // 0: cherche maison; 1: cherche nourriture; 2: retour maison
  public int step;
  
  Agent(Environment env_, int id_) {
    env = env_;
    id = id_;

    sensorFoodLeft = 0;
    sensorFoodFront = 0;
    sensorFoodRight = 0;
    sensorHomeLeft = 0;
    sensorHomeFront = 0;
    sensorHomeRight = 0;
    sensorCell = 0;
    etat = 0; // 0: cherche maison; 1: cherche nourriture; 2: retour maison
    explore = random(1);
    step = 0;
  }

  ////// TODO PART //////  
  public void step() {
        
    if (sensorCell == -1)
    {
      etat = 1;
      env.tryTurnAround(this);
      step = 0;
    }
    else if (sensorCell == 1)
    {
      etat = 2;
      env.tryTurnAround(this);
      step = 0;
    }
    if (etat == 0 || etat == 2)
    {
      if (sensorHomeLeft > sensorHomeFront && sensorHomeLeft > sensorHomeRight)
      {
         env.tryTurnLeft(this);
      }
      else if (sensorHomeRight > sensorHomeFront && sensorHomeRight > sensorHomeLeft)
      {
        env.tryTurnRight(this);
      }
    }
    else if (etat == 1)
    {
      if (sensorFoodLeft > sensorFoodFront && sensorFoodLeft > sensorFoodRight)
      {
        env.tryTurnLeft(this);
      }
      else if (sensorFoodRight > sensorFoodFront && sensorFoodRight > sensorFoodFront)
      {
        env.tryTurnRight(this);
      }
    }
    
    if (random(1) < explore)
    {
      env.tryTurnRandom(this); 
    }
    env.tryMove(this);
    step ++;
    float intensity = max(0, 1 - step / MAX_STEP);
    
    if (etat == 1)
    {
      env.tryDepositHomeMarker(this, intensity);
    }
    else if (etat == 2)
    {
      env.tryDepositFoodMarker(this, intensity);
    }
  }
  
}





























////////////////////////////////////////////////////////////////////////
