PMatrix3D pv;
PMatrix3D [] mv;
PMatrix3D mv_;
PImage [] img;
PImage img_;

int index = 0;

void setup()
{
  size(1280, 720, P3D);

  pv = new PMatrix3D(1.69032, 0.0, 0.0, 0.0, 
    0.0, -3.0050135, 0.0, 0.0, 
    0.0, -0.0027777778, 1.002002, 1.0, 
    0.0, 0.0, -4.004004, 0.0);
  pv.transpose();

  pv.print();
  printMatrix();
  //applyMatrix(pv);
  printMatrix();

  mv = new PMatrix3D[6];

  mv[0] = new PMatrix3D(0.9995132, 0.004341676, 0.03089542, 0.0, 
    0.0059285704, -0.9986576, -0.051458698, 0.0, 
    0.030630523, 0.05161681, -0.9981972, 0.0, 
    -10.422494, 4.2534933, 236.47314, 1.0);

  mv[1] = new PMatrix3D(0.9998356, 0.0043885736, 0.017598558, 0.0, 
    0.0056207767, -0.9974896, -0.070590734, 0.0, 
    0.017244587, 0.07067805, -0.9973501, 0.0, 
    -14.334564, 2.556219, 453.95117, 1.0);

  mv[2] = new PMatrix3D(0.77635086, 0.058464825, -0.6275838, 0.0, 
    0.019611899, -0.9974474, -0.068659954, 0.0, 
    -0.629996, 0.0409961, -0.7755157, 0.0, 
    -13.103903, 5.684967, 298.6713, 1.0);

  mv[3] = new PMatrix3D(0.99740285, -0.009295926, -0.07142218, 0.0, 
    0.03843405, -0.7699544, 0.63694036, 0.0, 
    -0.06091277, -0.6380312, -0.76759744, 0.0, 
    -8.147309, -4.703187, 277.7804, 1.0);

  mv[4] = new PMatrix3D(0.99991685, -0.012891272, 3.9367346E-4, 0.0, 
    -0.00911498, -0.72794336, -0.6855767, 0.0, 
    0.009124527, 0.6855161, -0.72800034, 0.0, 
    -10.364401, -4.108573, 257.59558, 1.0);

  mv[5] = new PMatrix3D(0.7313617, 0.07215277, -0.67816234, 0.0, 
    -0.013186403, -0.9927057, -0.11983932, 0.0, 
    -0.6818624, 0.096588396, -0.7250755, 0.0, 
    -63.31185, 7.3395066, 301.61255, 1.0);

  mv_ = mv[0];

  img = new PImage[6];
  img[0] = loadImage("vu_10394.jpg");
  img[1] = loadImage("vu_18200.jpg");
  img[2] = loadImage("vu_25181.jpg");
  img[3] = loadImage("vu_33263.jpg");
  img[4] = loadImage("vu_40123.jpg");
  img[5] = loadImage("vu_47327.jpg");

  img_ = img[0];
}

void draw()
{
  background(img[index]);
  //image(img[index], 0, 0);

  translate(width/2, height/2, -433); // -433

  //applyMatrix(new PMatrix3D());
  //applyMatrix(pv);

  PMatrix3D mv___ = mv_.get();
  //mv___.transpose();
  float [] mv__ = new float[16];
  mv___.get(mv__);
  mv__[11] = -mv__[11];
  //mv___.set(mv__);

  applyMatrix(mv___);

  /*float [] mv__ = new float[16];
   mv_.get(mv__);
   translate(mv__[3], mv__[7], -mv__[11]);
   
   float c = acos(mv__[0]);
   float s = asin(mv__[2]);
   rotateY(
   */
  //applyMatrix(pv);

  //translate(0, 0, mouseY);

  //translate(0, 0, mouseY);
  fill(255, 100, 0, 100);
  stroke(255, 100);
  box(200);
}

void keyPressed()
{
  if (keyCode == RIGHT)
  {
    if (index < mv.length-1)
      index ++;
    else
      index = 0;

    mv_ = mv[index];

    println(mv[index]);
  } else if (keyCode == LEFT)
  {
    if (index > 0)
      index --;
    else
      index = mv.length-1;

    mv_ = mv[index];

    println(mv[index]);
  }

  if (key == 't')
    mv_.transpose();
  else if (key == 'i')
    mv_.invert();
  else if (key == 'p')
    saveFrame("overlay_####.jpg");

  mv_.print();
}