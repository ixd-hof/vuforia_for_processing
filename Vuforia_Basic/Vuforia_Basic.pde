import android.app.Activity; //<>//
import android.os.Environment;
import android.os.Bundle;
import java.nio.ByteBuffer;
import android.graphics.Bitmap;
import android.graphics.Bitmap.Config;

import com.qualcomm.vuforia.*;
import com.qualcomm.vuforia.CameraCalibration;
import com.qualcomm.vuforia.CameraDevice;
import com.qualcomm.vuforia.Matrix44F;
import com.qualcomm.vuforia.Renderer;
import com.qualcomm.vuforia.State;
import com.qualcomm.vuforia.Tool;
import com.qualcomm.vuforia.Vec2I;
import com.qualcomm.vuforia.VideoBackgroundConfig;
import com.qualcomm.vuforia.VideoMode;
import com.qualcomm.vuforia.Vuforia;
import com.qualcomm.vuforia.Vuforia.UpdateCallbackInterface;
import com.qualcomm.vuforia.Frame;

int mVuforiaFlags = Vuforia.GL_20;
int mProgressValue;
State state;
ObjectTracker objectTracker;
Matrix44F mProjectionMatrix;
Matrix44F modelViewMatrixMat44f;

boolean camera_setup, tracker_setup;
String result;

PImage image;

void setup()
{
  size(displayWidth, displayHeight, P3D);
  //orientation(LANDSCAPE);
}

@Override
  //public void onCreate(Bundle savedInstanceState)
  public void onResume()
{
  //super.onCreate(savedInstanceState);
  //println("onCreate");
  super.onResume();
  println("onResume");

  Vuforia.setInitParameters(this.getActivity(), mVuforiaFlags, "//YOUR//OWN//VUFORIA//KEY//");

  do
  {
    mProgressValue = Vuforia.init();
    println(millis() + " " + mProgressValue);
  }
  while (mProgressValue >= 0 && mProgressValue < 100);
}

void draw()
{
  background(0);

  if (mProgressValue >= 100 && camera_setup == false && tracker_setup == false)
  {
    // Start the tracker
    TrackerManager tman = TrackerManager.getInstance(); 
    //Tracker tracker = tman.getTracker(ImageTracker.getClassType());
    objectTracker = (ObjectTracker)tman.initTracker(ObjectTracker.getClassType());

    //println("ObjectTracker: " + objectTracker);
    DataSet dest = objectTracker.createDataSet();
    boolean loaded = dest.load("FirstTarget.xml", STORAGE_TYPE.STORAGE_APPRESOURCE);
    objectTracker.activateDataSet(dest);
    println("ObjectTracker: " + loaded);

    tracker_setup = true;
  }

  if (mProgressValue >= 100 && camera_setup == false && tracker_setup == true)
  {
    CameraDevice.getInstance().init(CameraDevice.CAMERA.CAMERA_DEFAULT);

    //configureVideoBackground();

    CameraDevice.getInstance().selectVideoMode(CameraDevice.MODE.MODE_DEFAULT);
    Vuforia.setFrameFormat(PIXEL_FORMAT.RGB565, true);
    CameraDevice.getInstance().setFocusMode(CameraDevice.FOCUS_MODE.FOCUS_MODE_CONTINUOUSAUTO);

    VideoBackgroundTextureInfo texInfo = Renderer.getInstance().getVideoBackgroundTextureInfo();
    println(texInfo);

    state = Renderer.getInstance().begin();

    /*
    
     VideoBackgroundConfig config = new VideoBackgroundConfig();
     config.setEnabled(true);
     config.setPosition(new Vec2I(0, 0));
     config.setSize(new Vec2I(displayWidth, displayHeight));
     Renderer.getInstance().setVideoBackgroundConfig(config);
     */

    CameraDevice.getInstance().start();

    CameraCalibration camCal = CameraDevice.getInstance().getCameraCalibration();
    mProjectionMatrix = Tool.getProjectionGL(camCal, 2.0f, 2000.0f);

    float[] m = mProjectionMatrix.getData();
    println("Camera Calibration");
    println(m[0]+" "+m[1]+" "+m[2]+" "+m[3]);
    println(m[4]+" "+m[5]+" "+m[6]+" "+m[7]);
    println(m[8]+" "+m[9]+" "+m[10]+" "+m[11]);
    println(m[12]+" "+m[13]+" "+m[14]+" "+m[15]);
    println("----------------------");

    //PGraphicsOpenGL pg = (PGraphicsOpenGL) g;
    //pg = (PGraphicsOpenGL) g;
    PMatrix3D pm = new PMatrix3D();
    pm.set(m);
    //pg.projection = pm;

    camera_setup = true;
    println("Camera set up");
    //delay(1000);

    objectTracker.start();
  }

  if (camera_setup == true)
  {
    state = Renderer.getInstance().begin();
    Frame f = state.getFrame();
    //println("Images: " + f.getNumImages());
    if (f.getNumImages() > 1)
    {
      ByteBuffer pixels = f.getImage(1).getPixels();
      byte[] pixelArray = new byte[pixels.remaining()];
      pixels.get(pixelArray, 0, pixelArray.length);
      int imageWidth = f.getImage(1).getWidth();
      int imageHeight = f.getImage(1).getHeight();
      //int stride = imageRGB565.getStride();
      Bitmap bitmap = Bitmap.createBitmap(imageWidth, imageHeight, Bitmap.Config.RGB_565);
      bitmap.copyPixelsFromBuffer(ByteBuffer.wrap(pixelArray));

      image = new PImage(bitmap);

      println("Camera Image: " + image.width + ":" + image.height);
      println("----------------------");
      hint(DISABLE_DEPTH_MASK);
      image(image, 0, 0);
      hint(ENABLE_DEPTH_MASK);

      int results = state.getNumTrackableResults();
      int trackables = state.getNumTrackables();
      result = results + " / " + trackables;

      //println(results);

      if (results > 0)
      {
        TrackableResult trackableResult = state.getTrackableResult(0);
        modelViewMatrixMat44f = Tool.convertPose2GLMatrix(trackableResult.getPose());

        pushMatrix();

        //float[] m = modelViewMatrixMat44f.getData();
        PMatrix3D m = new PMatrix3D();
        m.set(modelViewMatrixMat44f.getData());
        //PGraphicsOpenGL pg = (PGraphicsOpenGL) g;
        //pg = (PGraphicsOpenGL) g;
        m.transpose();
        //pg.modelview = m;
        //
        //m.invert();
        //m.scale(10);

        //m.print();
        println("----------------------");
        /*
        println(m[0]+" "+m[1]+" "+m[2]+" "+m[3]);
         println(m[4]+" "+m[5]+" "+m[6]+" "+m[7]);
         println(m[8]+" "+m[9]+" "+m[10]+" "+m[11]);
         println(m[12]+" "+m[13]+" "+m[14]+" "+m[15]);
         println("----------------------");
         */

        /*
        applyMatrix(m[0], m[1], m[2], pos_x,
         m[4], m[5], m[6], pos_y,
         m[8], m[9], m[10], 0,
         m[12], m[13], m[14], m[15]);
         */
        /*
        applyMatrix(m[0], m[1], m[2], m[3], 
         m[4], m[5], m[6], m[7], 
         m[8], m[9], m[10], m[11], 
         m[12], m[13], m[14], m[15]);
         */
        translate(width/2, height/2, 0);
        //applyMatrix(m);

        float [] mm = new float[16];
        m.get(mm);

        translate(mm[3], mm[7], -mm[11]);

        printMatrix();

        //scale(0.01);
        //translate(0, 0, pos_z);
        stroke(255, 100, 0);
        fill(255);
        box(100);
        //image(image, 0, 0, 100, 100);
        popMatrix();
      }
    }
    Renderer.getInstance().end();
  }

  translate(width/2, height/2);
  textSize(80);
  text("AR " + result, 0, 0);
  stroke(255);
  noFill();
  rectMode(CENTER);
  for (int i=0; i<20; i++)
  {
    rotate(sin(millis()/1000.0+i));
    rect(0, 0, width/2, width/2);
  }
}

void mousePressed()
{
  File storageDir = Environment.getExternalStorageDirectory();
  if ( storageDir != null )
  {
    String fileName = new File(storageDir, "/Pictures/vu_" + millis()+ ".jpg").getAbsolutePath();
    println(fileName);
    image.save(fileName);
    
    float[] m = mProjectionMatrix.getData();
    String [] matrix = new String[11];
    matrix[0] = "Projection Matrix";
    matrix[1] =  "{ " + m[0]+", "+m[1]+", "+m[2]+", "+m[3]+", ";
    matrix[2] =  m[4]+", "+m[5]+", "+m[6]+", "+m[7]+", ";
    matrix[3] = m[8]+", "+m[9]+", "+m[10]+", "+m[11]+", ";
    matrix[4] = m[12]+", "+m[13]+", "+m[14]+", "+m[15]+" };";
    matrix[5] = "----------------------";
    
    m = modelViewMatrixMat44f.getData();
    matrix[6] = "Modelview Matrix";
    matrix[7] =  "{ " + m[0]+", "+m[1]+", "+m[2]+", "+m[3]+", ";
    matrix[8] =  m[4]+", "+m[5]+", "+m[6]+", "+m[7]+", ";
    matrix[9] = m[8]+", "+m[9]+", "+m[10]+", "+m[11]+", ";
    matrix[10] = m[12]+", "+m[13]+", "+m[14]+", "+m[15]+" };";
    
    println(matrix);
    
    
    fileName = new File(storageDir, "/Pictures/vu_" + millis()+ ".txt").getAbsolutePath();
    saveStrings(fileName, matrix);
    
    println("saved");
  }
}